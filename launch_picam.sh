#!/bin/bash

# Source ROS2 environment
source /opt/ros/$ROS_DISTRO/setup.bash
# Source workspace overlay
source "$(dirname "$0")/install/setup.bash"

# Launch the camera node (default)
ros2 run camera_ros camera_node
