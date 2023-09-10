#!/bin/bash

source /opt/ros/humble/setup.bash
source /opt/greengrass_bridge/setup.bash
source /opt/ros_demos/setup.bash

printenv

exec "${@:1}"
