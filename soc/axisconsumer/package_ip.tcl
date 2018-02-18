

set design axisconsumer
set root "."
set projdir $root

set partname "xc7a35ticsg324-1L"
set boardpart "digilentinc.com:arty-a7-35:part0:1.0"

set hdl_files [list $root/hdl/]
set ip_files []

# Create project
create_project -force $design $projdir -part $partname
set_property target_language VHDL [current_project]
set_property source_mgmt_mode None [current_project]
if {$boardpart != ""} {
set_property "board_part" $boardpart [current_project]
}

if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}


add_files -norecurse -fileset [get_filesets sources_1] $hdl_files
set_property top $design [get_filesets sources_1]

# Synthesize

#set_property top $design [current_fileset]
#launch_runs synth_1 -jobs 6
#wait_on_run synth_1


# Package
ipx::package_project -import_files -force -root_dir $projdir
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core [concat $projdir/$design.zip] [ipx::current_core]
close_project
quit
