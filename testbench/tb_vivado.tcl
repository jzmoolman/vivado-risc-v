
# If there is no project opened, create a project
set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project -force tb-${vivado_board_name}-riscv tb-vivado-${vivado_board_name}-riscv -part ${xilinx_part}
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
 [file normalize "../../testbench/tb_vivado.v"] \
 [file normalize "../../testbench/axi_ram.v"] 
]

add_files -norecurse -fileset $source_fileset $files

# Note: top.xdc must be first - other files depend on clocks defined in top.xdc
set files [list \
 [file normalize ../../board/${vivado_board_name}/top.xdc] 
]

add_files -norecurse -fileset $constraint_fileset $files

source ../../testbench/tb_blockdesign.tcl
make_wrapper -files [get_files ./tb-vivado-genesys2-riscv/tb-genesys2-riscv.srcs/sources_1/bd/design_1/design_1.bd] -top
import_files -force -norecurse ./tb-vivado-genesys2-riscv/tb-genesys2-riscv.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
update_compile_order -fileset sources_1

set_property top tb_rocketchip [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]



