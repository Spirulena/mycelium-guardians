#!/bin/bash
#mkdir -p ../../builds/f87b81b/Steam/0.0.62_bc02ee01/win/
#mkdir -p ../../builds/f87b81b/Steam/0.0.62_bc02ee01/lin/
#mkdir -p ../../builds/f87b81b/Steam/0.0.62_bc02ee01/mac/

godot --headless --export-release "Linux_Demo" && \
godot --headless --export-release "Windows_Demo" && \
godot --headless --export-release "macOS_Demo" && \
echo $? && \
find ../../builds/f87b81b/Steam/demo/


godot --headless --export-release "Linux_Release" && \
godot --headless --export-release "Windows_Release" && \
godot --headless --export-release "macOS_Release" && \
echo $? && \
find ../../builds/f87b81b/Steam/release/

cd ~/dev/steam/sdk/tools/ContentBuilder/builder_linux
./steamcmd.sh +login s +run_app_build /home/m/d/s/g-waffle/Steam/linux/app_2.vdf +quit && ./steamcmd.sh +login s +run_app_build /home/m/d/s/g-w/Steam/linux/app_3.vdf +quit
cd -

godot --headless --export-release "linux_steam_dev" && \
godot --headless --export-release "windows_steam_dev" && \
godot --headless --export-release "mac_steam_dev" && \
echo $? && \
find ../../builds/f87b81b/Steam/dev/

