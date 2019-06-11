# roslib

A library for communicating to a ROS node over websockets with rosbridge, heavily influenced by roslibjs and follows the same structure.

**THIS IS AN INCOMPLETE LIBRARY**

## List of feature implementation statuses (essentially a list of features required to reach roslibjs's level)
- [X] Core:
  - [x] ROS connection object
  - [x] Topic object (subscribe, unsubscribe, publish, advertise, unadvertise)
  - [x] Service object (call, advertise, unadvertise)
  - [x] Request object (provides typing and naming to any potential ROS request)
  - [x] Param object (get, set, delete)
- [ ] Actionlib:
  - [ ] ActionClient
  - [ ] ActionListener
  - [ ] Goal
  - [ ] SimpleActionServer
- [ ] Support TCP connections
- [ ] TFClient (listen to TFs from tf2_web_republisher
- [ ] URDF (Box, Color, Cylinder, Joint, Material, Mesh, Model, Sphere, Types, Visual)
- [ ] 

## Testing

In order to successfully run the tests a ros node must be accessible with packages `ros-{distro}-rosbridge-server` and `ros-{distro}-rospy-tutorials` installed. And it must be running these three processes:
1. `roscore`
2. `rlaunch rosbridge_server rosbridge_websocket.launch`
3. `rosrun rospy_tutorials add_two_ints_server`
