
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
 [file normalize ../../board/${vivado_board_name}/top.xdc] \
# [file normalize ../../board/timing-constraints.tcl] 
]

add_files -norecurse -fileset $constraint_fileset $files



