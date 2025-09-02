#!/bin/bash

# Source ROS2 environment
source /opt/ros/$ROS_DISTRO/setup.bash
# Source workspace overlay
source "$(dirname "$0")/install/setup.bash"

# Set ROS networking for multi-device access
export ROS_LOCALHOST_ONLY=0
IP=$(hostname -I | awk '{print $1}')
if [ -n "$IP" ]; then
    export ROS_IP=$IP
    echo "ROS_IP set to $IP"
else
    echo "Warning: No IP address detected"
fi

# Launch the camera node (default)
ros2 run camera_ros camera_node
