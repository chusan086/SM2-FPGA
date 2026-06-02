# create_sm2_prj.tcl
# Creates Vivado project for SM2 elliptic curve crypto core
# Target board: RK-ZYNQ7100-F (XC7Z100-FFG900-2)
# Vivado version: 2023.1

# Create project
create_project -force sm2_prj1 ./sm2_prj1 -part xc7z100ffg900-2
set_property target_language Verilog [current_project]

# Add RTL sources
add_files -norecurse [glob ../rtl/*.sv]
set_property SOURCE_SET sources_1 [get_filesets sources_1]

# Add simulation sources
add_files -norecurse -fileset sim_1 [glob ../sim/*.sv]
set_property SOURCE_SET sim_1 [get_filesets sim_1]

# Add constraints
add_files -norecurse -fileset constrs_1 ../constr/sm2_prj1.xdc
set_property SOURCE_SET constrs_1 [get_filesets constrs_1]

# Add IP cores
add_files -norecurse [glob ../ip/*/*.xci]
set_property SOURCE_SET sources_1 [get_filesets sources_1]

# Set top module
set_property top c1_cal [current_fileset]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project created successfully."
puts "Part: xc7z100ffg900-2"
puts "Open the project with: vivado sm2_prj1/sm2_prj1.xpr"
