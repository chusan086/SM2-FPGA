# create_project.tcl
# Creates Vivado project for the SM2 curve arithmetic core
# Target board: RK-ZYNQ7100-F (XC7Z100-FFG900-2)
# Vivado version: 2023.1

set script_dir [file dirname [file normalize [info script]]]
set repo_dir [file normalize [file join $script_dir ".."]]
set project_dir [file join $repo_dir "build" "sm2_prj1"]

# Create project
create_project -force sm2_prj1 $project_dir -part xc7z100ffg900-2
set_property target_language Verilog [current_project]

# Add RTL sources
add_files -norecurse [glob [file join $repo_dir "rtl" "*.sv"]]

# Board-level demo top. The file is kept in sim/ in the original project tree,
# but it is the synthesis top used by the checked-in .xpr.
add_files -norecurse [file join $repo_dir "sim" "c1_test.sv"]
set_property SOURCE_SET sources_1 [get_filesets sources_1]

# Add simulation sources
add_files -norecurse -fileset sim_1 [glob [file join $repo_dir "sim" "*testbench.sv"]]
set_property SOURCE_SET sim_1 [get_filesets sim_1]

# Add constraints
add_files -norecurse -fileset constrs_1 [file join $repo_dir "constr" "sm2_prj1.xdc"]
set_property SOURCE_SET constrs_1 [get_filesets constrs_1]

# Add IP cores
add_files -norecurse [glob [file join $repo_dir "ip" "*" "*.xci"]]
set_property SOURCE_SET sources_1 [get_filesets sources_1]

# Set top module
set_property top c1_test [current_fileset]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project created successfully."
puts "Part: xc7z100ffg900-2"
puts "Project path: $project_dir"
puts "Open the project with: vivado [file join $project_dir sm2_prj1.xpr]"
