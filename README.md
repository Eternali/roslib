# roslib

A library for communicating to a ROS node over websockets, heavily influenced by roslibjs.

## Testing

In order to successfully run the tests a ros node must be accessible with packages `ros-{distro}-rosbridge-server` and `ros-{distro}-rospy-tutorials` installed. And it must be running these three processes:
1. `roscore`
2. `rlaunch rosbridge_server rosbridge_websocket.launch`
3. `rosrun rospy_tutorials add_two_ints_server`
