BOARD ?= genesys2
CONFIG ?= rocket64b2
include board/$(BOARD)/MakeFile.inc

#Director used to create bootrom.img
BOOTROM=bootrom_debug
#BOOTROM=bootrom

$(info Running Script)

# --- packages and repos ---
apt-install:
	brew install riscv-tools


SKIP_SUBMODULES = torture software/gemmini-rocc-tests software/onnxruntime-riscv linux-stable

update-submodules:
	rm -rf workspace/patch-*-done
	git submodule sync --recursive
	git $(foreach m,$(SKIP_SUBMODULES),-c submodule.$(m).update=none) submodule update --init --force --recursive



# --- generate HDL ---

workspace/boot.elf:
	touch boot.elf

CONFIG_SCALA := $(subst rocket,Rocket,$(CONFIG))
RISCV_TOOLS_PATH ?= /opt/homebrew/bin/

# valid ROCKET_FREQ_MHZ values (MHz): 160 125 100 80 62.5 50 40 31.25 25 20
ROCKET_FREQ_MHZ ?= $(shell awk '$$3 != "" && "$(BOARD)" ~ $$1 && "$(CONFIG_SCALA)" ~ ("^" $$2 "$$") {print $$3; exit}' board/rocket-freq)

ROCKET_CLOCK_FREQ := $(shell echo - | awk '{printf("%.0f\n", $(ROCKET_FREQ_MHZ) * 1000000)}')
ROCKET_TIMEBASE_FREQ := $(shell echo - | awk '{printf("%.0f\n", $(ROCKET_FREQ_MHZ) * 10000)}')

MEMORY_SIZE ?= 0x40000000

ifneq ($(findstring Rocket32t,$(CONFIG_SCALA)),)
  CROSS_COMPILE_NO_OS_TOOLS = $(RISCV_TOOLS_PATH)/riscv32-unknown-elf-
  CROSS_COMPILE_NO_OS_FLAGS = -march=rv32gc -mabi=ilp32 -DFF_FS_EXFAT=0
else ifneq ($(findstring Rocket32,$(CONFIG_SCALA)),)
  CROSS_COMPILE_NO_OS_TOOLS = $(RISCV_TOOLS_PATH)/riscv32-unknown-elf-
  CROSS_COMPILE_NO_OS_FLAGS = -march=rv32gc -mabi=ilp32
else
  CROSS_COMPILE_NO_OS_TOOLS = $(RISCV_TOOLS_PATH)/riscv64-unknown-elf-
  CROSS_COMPILE_NO_OS_FLAGS = -march=rv64gc -mabi=lp64
endif

ifeq ($(shell echo $$(($(MEMORY_SIZE) <= 0x80000000))),1)
  MEMORY_ADDR_RANGE32 = 0x80000000 $(MEMORY_SIZE)
  MEMORY_ADDR_RANGE64 = 0x0 0x80000000 0x0 $(MEMORY_SIZE)
else
  MEMORY_ADDR_RANGE32 = 0x80000000 0x80000000
  MEMORY_SIZE_CPU = ${shell cat workspace/$(CONFIG)/system.dts | sed -n 's/.*reg = <0x0 0x80000000 *\(0x[0-9A-Fa-f]*\) *0x\([0-9A-Fa-f]*\)>.*/\1\2/p'}
  MEMORY_SIZE_AWK = if (CPU < DDR) SIZE=CPU; else SIZE=DDR; printf "0x%x 0x%x", SIZE / 0x100000000, SIZE % 0x100000000
  MEMORY_ADDR_RANGE64 = 0x0 0x80000000 $(shell echo - | awk '{CPU=$(MEMORY_SIZE_CPU); DDR=$(MEMORY_SIZE); $(MEMORY_SIZE_AWK)}')
endif

SBT := java -Xmx12G -Xss8M $(JAVA_OPTIONS) -Dsbt.io.virtual=false -Dsbt.server.autostart=false -jar $(realpath sbt-launch.jar)

CHISEL_SRC_DIRS = \
  src/main \
  rocket-chip/src/main \
  rocket-chip/macros/src/main \
  rocket-chip/hardfloat/src/main \
  generators/gemmini/src/main \
  generators/riscv-boom/src/main \
  generators/sifive-cache/design/craft \
  generators/testchipip/src/main

CHISEL_SRC := $(foreach path, $(CHISEL_SRC_DIRS), $(shell test -d $(path) && find $(path) -iname "*.scala" -not -name ".*"))
FIRRTL = java -Xmx12G -Xss8M $(JAVA_OPTIONS) -cp `realpath target/scala-*/system.jar` firrtl.stage.FirrtlMain

workspace/patch-hdl-done:
	if [ -s patches/ethernet.patch ] ; then cd ethernet/verilog-ethernet && ( git apply -R --check ../../patches/ethernet.patch 2>/dev/null || git apply ../../patches/ethernet.patch ) ; fi
	if [ -s patches/rocket-chip.patch ] ; then cd rocket-chip && ( git apply -R --check ../patches/rocket-chip.patch 2>/dev/null || git apply ../patches/rocket-chip.patch ) ; fi
	if [ -s patches/riscv-boom.patch ] ; then cd generators/riscv-boom && ( git apply -R --check ../../patches/riscv-boom.patch 2>/dev/null || git apply ../../patches/riscv-boom.patch ) ; fi
	if [ -s patches/sifive-cache.patch ] ; then cd generators/sifive-cache && ( git apply -R --check ../../patches/sifive-cache.patch 2>/dev/null || git apply ../../patches/sifive-cache.patch ) ; fi
	if [ -s patches/gemmini.patch ] ; then cd generators/gemmini && ( git apply -R --check ../../patches/gemmini.patch 2>/dev/null || git apply ../../patches/gemmini.patch ) ; fi
	mkdir -p workspace && touch workspace/patch-hdl-done

# Generate default device tree - not including peripheral devices or board specific data
workspace/$(CONFIG)/system.dts: $(CHISEL_SRC) rocket-chip/bootrom/bootrom.img workspace/patch-hdl-done
	rm -rf workspace/$(CONFIG)/tmp
	mkdir -p workspace/$(CONFIG)/tmp
	cp rocket-chip/bootrom/bootrom.img workspace/bootrom2.img
	$(SBT) "runMain freechips.rocketchip.diplomacy.Main --dir `realpath workspace/$(CONFIG)/tmp` --top Vivado.RocketSystem --config Vivado.$(CONFIG_SCALA)"
	mv workspace/$(CONFIG)/tmp/Vivado.$(CONFIG_SCALA).dts workspace/$(CONFIG)/system.dts
	rm -rf workspace/$(CONFIG)/tmp

# Generate board specific device tree, boot ROM and FIRRTL
workspace/$(CONFIG)/system-$(BOARD)/RocketSystem.fir: workspace/$(CONFIG)/system.dts $(wildcard $(BOOTROM)/*)
	rm -rf workspace/$(CONFIG)/system-$(BOARD)
	mkdir -p workspace/$(CONFIG)/system-$(BOARD)
	cat workspace/$(CONFIG)/system.dts board/$(BOARD)/bootrom.dts >$(BOOTROM)/system.dts
	sed -i='' "s#reg = <0x80000000 *0x.*>#reg = <$(MEMORY_ADDR_RANGE32)>#g" $(BOOTROM)/system.dts
	sed -i='' "s#reg = <0x0 0x80000000 *0x.*>#reg = <$(MEMORY_ADDR_RANGE64)>#g" $(BOOTROM)/system.dts
	sed -i='' "s#clock-frequency = <[0-9]*>#clock-frequency = <$(ROCKET_CLOCK_FREQ)>#g" $(BOOTROM)/system.dts
	sed -i='' "s#timebase-frequency = <[0-9]*>#timebase-frequency = <$(ROCKET_TIMEBASE_FREQ)>#g" $(BOOTROM)/system.dts
	if [ ! -z "$(ETHER_MAC)" ] ; then sed -i "s#local-mac-address = \[.*\]#local-mac-address = [$(ETHER_MAC)]#g" $(BOOTROM)/system.dts ; fi
	if [ ! -z "$(ETHER_PHY)" ] ; then sed -i "s#phy-mode = \".*\"#phy-mode = \"$(ETHER_PHY)\"#g" $(BOOTROM)/system.dts ; fi
	sed -i=''  "/interrupts-extended = <&.* 65535>;/d" $(BOOTROM)/system.dts
	make -C $(BOOTROM) CROSS_COMPILE="$(CROSS_COMPILE_NO_OS_TOOLS)" CFLAGS="$(CROSS_COMPILE_NO_OS_FLAGS)" BOARD=$(BOARD) clean bootrom.img
	mv $(BOOTROM)/system.dts workspace/$(CONFIG)/system-$(BOARD).dts
	mv $(BOOTROM)/bootrom.img workspace/bootrom.img
	$(SBT) "runMain freechips.rocketchip.diplomacy.Main --dir `realpath workspace/$(CONFIG)/system-$(BOARD)` --top Vivado.RocketSystem --config Vivado.$(CONFIG_SCALA)"
	$(SBT) assembly
	#rm workspace/bootrom.img

# Generate Rocket SoC HDL
workspace/$(CONFIG)/system-$(BOARD).v: workspace/$(CONFIG)/system-$(BOARD)/RocketSystem.fir
	$(FIRRTL) -i $< -o RocketSystem.v --compiler verilog \
	  --annotation-file workspace/$(CONFIG)/system-$(BOARD)/RocketSystem.anno.json \
	  --custom-transforms firrtl.passes.InlineInstances \
	  --target:fpga
	cp workspace/$(CONFIG)/system-$(BOARD)/RocketSystem.v workspace/$(CONFIG)/system-$(BOARD).v

# Generate Rocket SoC wrapper for Vivado
workspace/$(CONFIG)/rocket.vhdl: workspace/$(CONFIG)/system-$(BOARD).v
	mkdir -p vhdl-wrapper/bin
	javac -g -nowarn \
	  -sourcepath vhdl-wrapper/src -d vhdl-wrapper/bin \
	  -classpath vhdl-wrapper/antlr-4.8-complete.jar \
	  vhdl-wrapper/src/net/largest/riscv/vhdl/Main.java
	java -Xmx4G -Xss8M $(JAVA_OPTIONS) -cp \
	  vhdl-wrapper/src:vhdl-wrapper/bin:vhdl-wrapper/antlr-4.8-complete.jar \
	  net.largest.riscv.vhdl.Main -m $(CONFIG_SCALA) \
	  workspace/$(CONFIG)/system-$(BOARD).v >$@


# --- utility make targets to run SBT command line ---


.PHONY: sbt rocket-sbt

sbt:
	$(SBT)

rocket-sbt:
	cd rocket-chip && $(SBT)

# --- generate Vivado Project ---

.PHONY: vivado-tcl

FPGA_FNM    ?= riscv_wrapper.bit

proj_name   = $(BOARD)-riscv
proj_path   = workspace/$(CONFIG)/vivado-$(proj_name)
proj_file   = $(proj_path)/$(proj_name).xpr
proj_time   = $(proj_path)/timestamp.txt
synthesis   = $(proj_path)/$(proj_name).runs/synth_1/riscv_wrapper.dcp
bitstream   = $(proj_path)/$(proj_name).runs/impl_1/$(FPGA_FNM)
cfgmem_file = workspace/$(CONFIG)/$(proj_name).$(CFG_FORMAT)
prm_file    = workspace/$(CONFIG)/$(proj_name).prm

workspace/$(CONFIG)/system-$(BOARD).tcl: workspace/$(CONFIG)/rocket.vhdl workspace/$(CONFIG)/system-$(BOARD).v
	echo "set vivado_board_name $(BOARD)" >$@
	if [ "$(BOARD_PART)" != "" -a "$(BOARD_PART)" != "NONE" ] ; then echo "set vivado_board_part $(BOARD_PART)" >>$@ ; fi
	if [ "$(BOARD_CONFIG)" != "" ] ; then echo "set board_config $(BOARD_CONFIG)" >>$@ ; fi
	echo "set xilinx_part $(XILINX_PART)" >>$@
	echo "set rocket_module_name $(CONFIG_SCALA)" >>$@
	echo "set riscv_clock_frequency $(ROCKET_FREQ_MHZ)" >>$@
	echo "set memory_size $(MEMORY_SIZE)" >>$@
	echo 'cd [file dirname [file normalize [info script]]]' >>$@
	echo 'source ../../vivado.tcl' >>$@
	echo "set vivado_board_name $(BOARD)" >workspace/${CONFIG}/tb-${BOARD}.tcl
	if [ "$(BOARD_PART)" != "" -a "$(BOARD_PART)" != "NONE" ] ; then echo "set vivado_board_part $(BOARD_PART)" >>workspace/${CONFIG}/tb-${BOARD}.tcl ; fi
	if [ "$(BOARD_CONFIG)" != "" ] ; then echo "set board_config $(BOARD_CONFIG)" >>workspace/${CONFIG}/tb-${BOARD}.tcl ; fi 
	echo "set xilinx_part $(XILINX_PART)" >>workspace/${CONFIG}/tb-${BOARD}.tcl
	echo "set rocket_module_name $(CONFIG_SCALA)" >>workspace/${CONFIG}/tb-${BOARD}.tcl
	echo "set riscv_clock_frequency $(ROCKET_FREQ_MHZ)" >>workspace/${CONFIG}/tb-${BOARD}.tcl
	echo "set memory_size $(MEMORY_SIZE)" >>workspace/${CONFIG}/tb-${BOARD}.tcl
	echo 'cd [file dirname [file normalize [info script]]]' >>workspace/${CONFIG}/tb-${BOARD}.tcl
	echo 'source ../../testbench/tb-vivado.tcl' >>workspace/${CONFIG}/tb-${BOARD}.tcl


vivado-tcl: workspace/$(CONFIG)/system-$(BOARD).tcl

github: workspace/$(CONFIG)/system-$(BOARD).tcl
	rm -rf ../vivado-workspace/$(CONFIG)
	cp -r workspace/$(CONFIG) ../vivado-workspace/
	git -C ../vivado-workspace add  .
	git -C ../vivado-workspace commit --amend -m "vivado-workspace"
	git -C ../vivado-workspace push -f

all:
	$(info "usage: make update-submodules"
