set system_dir "/home/jzmoolman/src/vivado-risc-v-jzm/vivado_workspace/Rocket64x1"
set vivado_board_name "genesys2"
set rocket_module_name Rocket64x1
set vivado_board_part digilentinc.com:genesys2:part0:1.1
set xilinx_part xc7k325tffg900-2


# If there is no project opened, create a project
set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project -force tb-${vivado_board_name}-riscv vivado-${vivado_board_name}-riscv -part ${xilinx_part}
   # Allow projects with no BOARD_PART set. xilinx_part and /board constraints can suffice.
   if {[info exists vivado_board_part]} {
      set_property BOARD_PART ${vivado_board_part} [current_project]
   }
}


set source_fileset [get_filesets sources_1]
set constraint_fileset [get_filesets constrs_1]

set files [list \
 [file normalize "${system_dir}/rocket.vhdl"] \
 [file normalize "${system_dir}/system-genesys2.v"] \
]

add_files -norecurse -fileset $source_fileset $files

# Note: top.xdc must be first - other files depend on clocks defined in top.xdc
set files [list \
 [file normalize ${system_dir}/../../board/${vivado_board_name}/top.xdc] \
]
add_files -norecurse -fileset $constraint_fileset $files
add_files -norecurse -fileset $constraint_fileset [file normalize ${system_dir}/../../board/timing-constraints.tcl]


set_property SOURCE_SET sources_1 [get_filesets sim_1]
import_files -fileset sim_1 -norecurse ${system_dir}/../../tb_vivado.v
update_compile_order -fileset sim_1

