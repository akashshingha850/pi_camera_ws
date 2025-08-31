# PiCam ROS2 Workspace

This ROS2 workspace provides camera support for Raspberry Pi using the `camera_ros` package built on top of `libcamera`. This setup enables access to various camera modules including V4L2 devices and Raspberry Pi Camera Modules through a standardized ROS2 interface.

## Overview

The workspace contains:
- **camera_ros**: ROS2 node for libcamera-supported cameras
- **libcamera**: Camera support library (Raspberry Pi fork with enhanced module support)

This implementation is based on [christianrauch/camera_ros](https://github.com/christianrauch/camera_ros) and provides compatibility with the ROS2 image_pipeline stack.

## Prerequisites

- ROS2 Humble or later
- Raspberry Pi OS or Ubuntu
- Camera module connected to Raspberry Pi

## Installation & Setup

### 1. Source ROS2 Environment
```bash
source /opt/ros/$ROS_DISTRO/setup.bash
```

### 2. Install Dependencies
```bash
cd ~/camera_ws
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO --skip-keys=libcamera
```

### 3. Build the Workspace
```bash
colcon build --event-handlers=console_direct+
```

### 4. Source the Workspace
```bash
source install/setup.bash
```

## Usage

### Basic Camera Node
Launch the camera node with default settings:
```bash
ros2 run camera_ros camera_node
```

### Using Launch File
Launch with the provided launch configuration:
```bash
ros2 launch camera_ros camera.launch.py
```

### Composable Node
Run as a composable component:
```bash
ros2 component standalone camera_ros camera::CameraNode
```

## Configuration

### Static Parameters (set at startup)

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `camera` | int/string | Camera selection by index or name | 0 |
| `role` | string | Stream role (raw, still, video, viewfinder) | viewfinder |
| `format` | string | Pixel format supported by camera | auto |
| `width` | int | Image width | auto |
| `height` | int | Image height | auto |
| `sensor_mode` | string | Raw sensor format (width:height) | auto |
| `orientation` | int | Camera orientation (0, 90, 180, 270) | 0 |
| `frame_id` | string | Frame ID for image messages | camera_frame |
| `camera_info_url` | string | Camera calibration file URL | ~/.ros/camera_info/$NAME.yaml |

### Example Parameter Usage
```bash
# Set specific resolution and format
ros2 run camera_ros camera_node --ros-args \
  -p width:=1920 \
  -p height:=1080 \
  -p format:=YUYV \
  -p frame_id:=pi_camera

# Set framerate (20 Hz = 50ms frame duration)
ros2 run camera_ros camera_node --ros-args \
  -p FrameDurationLimits:="[50000,50000]"
```

## Topics and Services

### Published Topics
- `~/image_raw` (sensor_msgs/msg/Image) - Raw camera images
- `~/image_raw/compressed` (sensor_msgs/msg/CompressedImage) - Compressed images
- `~/camera_info` (sensor_msgs/msg/CameraInfo) - Camera calibration parameters

### Services
- `~/set_camera_info` (sensor_msgs/srv/SetCameraInfo) - Set camera calibration parameters

## Camera Calibration

The node uses `CameraInfoManager` for camera parameter management. Calibration files are expected at:
```
~/.ros/camera_info/$CAMERA_NAME.yaml
```

To calibrate your camera:
```bash
# Install camera calibration tools
sudo apt install ros-$ROS_DISTRO-camera-calibration

# Run calibration
ros2 run camera_calibration cameracalibrator \
  --size 8x6 --square 0.108 \
  image:=/camera/image_raw camera:=/camera
```

## Troubleshooting

### Camera Detection Issues
1. **Check camera connection:**
   ```bash
   # For USB cameras
   lsusb
   v4l2-ctl --list-devices
   
   # For Raspberry Pi cameras
   sudo vclog --msg
   ```

2. **Verify libcamera detection:**
   ```bash
   # List available cameras
   libcamera-hello --list-cameras
   ```

### Memory Issues
If you encounter buffer allocation errors:
- Increase GPU memory split: `sudo raspi-config` → Advanced Options → Memory Split
- Reduce image resolution using `width` and `height` parameters
- Use compressed formats like `YUYV` instead of `XRGB8888`

### Debug Mode
Enable verbose logging:
```bash
LIBCAMERA_LOG_LEVELS=*:DEBUG ros2 run camera_ros camera_node \
  --ros-args --log-level camera:=debug
```

## Supported Camera Modules

### Raspberry Pi Camera Modules
- **Camera Module 1** (OmniVision OV5647) - Supported by both upstream and Raspberry Pi libcamera
- **Camera Module 2** (Sony IMX219) - Supported by both versions
- **Camera Module 3** (Sony IMX708) - Requires Raspberry Pi libcamera fork
- **HQ Camera** (Sony IMX477) - Supported by both versions

### USB/V4L2 Cameras
Most standard USB webcams are supported through V4L2 interface.

## Development

### Adding Custom Parameters
Dynamic parameters are automatically generated from camera controls. Check available controls:
```bash
# View available camera controls
ros2 param list /camera_node
```

### Building from Source
This workspace already includes the source code. To update:
```bash
cd ~/camera_ws/src/camera_ros
git pull origin main

cd ~/camera_ws/src/libcamera
git pull origin main

cd ~/camera_ws
colcon build --event-handlers=console_direct+
```

## Integration Examples

### With Image Pipeline
```bash
# Install image pipeline
sudo apt install ros-$ROS_DISTRO-image-pipeline

# Launch camera with image processing
ros2 launch camera_ros camera.launch.py
ros2 run image_proc image_proc --ros-args --remap image_raw:=/camera/image_raw
```

### With OpenCV Bridge
```python
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image
from cv_bridge import CvBridge
import cv2

class ImageSubscriber(Node):
    def __init__(self):
        super().__init__('image_subscriber')
        self.subscription = self.create_subscription(
            Image, '/camera/image_raw', self.image_callback, 10)
        self.bridge = CvBridge()

    def image_callback(self, msg):
        cv_image = self.bridge.imgmsg_to_cv2(msg, "bgr8")
        cv2.imshow("Camera Feed", cv_image)
        cv2.waitKey(1)
```

## License

This workspace uses components under different licenses:
- camera_ros: MIT License
- libcamera: LGPL-2.1 License

## Additional Resources

- [Camera_ros Documentation](https://github.com/christianrauch/camera_ros)
- [libcamera Documentation](https://libcamera.org/)
- [Raspberry Pi Camera Documentation](https://www.raspberrypi.com/documentation/computers/camera_software.html)
- [ROS2 Image Pipeline](https://github.com/ros-perception/image_pipeline)
- [Pi Camrera with ROS2 in Ubuntu](https://github.com/raspberrypi/libcamera)

## Support

For issues specific to this workspace setup, check:
1. Ensure all dependencies are installed
2. Verify camera hardware is detected
3. Check ROS2 environment is properly sourced
4. Review log output for detailed error messages

For camera_ros specific issues, refer to the [upstream repository](https://github.com/christianrauch/camera_ros/issues).
