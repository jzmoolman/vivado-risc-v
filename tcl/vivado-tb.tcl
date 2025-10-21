
# If there is no project opened, create a project
set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project -force ${vivado_board_name}-riscv-tb vivado-${vivado_board_name}-riscv-tb -part ${xilinx_part}
   # Allow projects with no BOARD_PART set. xilinx_part and /board constraints can suffice.
   if {[info exists vivado_board_part]} {
      set_property BOARD_PART ${vivado_board_part} [current_project]
   }
}


set source_fileset [get_filesets sources_1]
set constraint_fileset [get_filesets constrs_1]

set files [list \
 [file normalize "rocket.vhdl"] \
 [file normalize "system-$vivado_board_name.v"] \
 [file normalize "soc_wrapper_tb.v"] \
 [file normalize "../../tb/vivado_tb.v"] \
 [file normalize "../../verilog-axi/rtl/axi_ram.v"] \
 [file normalize "../../../secure-memory/include/config_pkg.sv"] \
 [file normalize "../../../secure-memory/include/build_config_pkg.sv"] \
 [file normalize "../../../secure-memory/include/riscv_pkg.sv"] \
 [file normalize "../../../secure-memory/tilelink/include/tilelink_pkg.sv"] \
 [file normalize "../../../secure-memory/rtl/fifo_v3.sv"] \
 [file normalize "../../../secure-memory/rtl/csr_regfile.sv"] \
 [file normalize "../../../secure-memory/epmp/rtl/epmp.sv"] \
 [file normalize "../../../secure-memory/epmp/rtl/epmp_entry.sv"] \
 [file normalize "../../../secure-memory/rtl/lzc.sv"] \
 [file normalize "../../../secure-memory/rtl/cf_math_pkg.sv"] \
 [file normalize "../../../secure-memory/aes/src/rtl/aes_encipher_block.v"] \
 [file normalize "../../../secure-memory/aes/src/rtl/aes_sbox.v"] \
 [file normalize "../../../secure-memory/cipherblock/rtl/cipherblock.sv"] \
 [file normalize "../../../secure-memory/cipherblock/rtl/cipherblock_nx128.sv"] \
 [file normalize "../../../secure-memory/memory-controller/rtl/memory_controller_wrapper.sv"] \
 [file normalize "../../../secure-memory/memory-controller/rtl/secure_memory_controller.sv" ] \
 [file normalize "../../../secure-memory/memory-controller/rtl/memory_encryption_unit.sv" ] \
 [file normalize "../../../secure-memory/tilelink/rtl/ztl_assembler.sv"] \
 [file normalize "../../../secure-memory/tilelink/rtl/ztl_fragmenter.sv"] \
]

add_files -norecurse -fileset $source_fileset $files

# Note: top.xdc must be first - other files depend on clocks defined in top.xdc
set files [list \
 [file normalize ../../board/${vivado_board_name}/top.xdc] 
]

add_files -norecurse -fileset $constraint_fileset $files

set_property top vivado_tb [get_filesets sim_1]

set memfile "../../tb/init.mem"
if {[file exists $memfile]} {
   puts "File exists, adding to project..."
   add_files $memfile
   set_property verilog_define [list "MEMFILE_INCLUDED=1"] [get_filesets sim_1]
}


