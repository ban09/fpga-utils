

set design axisconsumer_test
set root "."
set projdir $root

set partname "xc7a35ticsg324-1L"
set boardpart "digilentinc.com:arty-a7-35:part0:1.0"

set ip_repos [list "../axisconsumer"]

# Create project
create_project -force $design $projdir -part $partname
set_property target_language VHDL [current_project]
set_property source_mgmt_mode None [current_project]
if {$boardpart != ""} {
set_property "board_part" $boardpart [current_project]
}

# IP repo
set other_repos [get_property ip_repo_paths [current_project]]
set_property ip_repo_paths "$ip_repos $other_repos" [current_project]
update_ip_catalog

# Block design
#create_bd_design "system"
source ./system_bd.tcl


# Synthesize

# Implement

# Generate bitstream

close_project
quit

