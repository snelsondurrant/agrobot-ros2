#!/bin/bash
# Created by Nelson Durrant, Sep 2024
#
# Starts the micro-ROS agent and ROS 2 launch files
# - Specify a start configuration using 'bash start.sh 
#   <launch>' (ex. 'bash start.sh moos')

function printInfo {
  echo -e "\033[0m\033[36m[INFO] $1\033[0m"
}

function printWarning {
  echo -e "\033[0m\033[33m[WARNING] $1\033[0m"
}

function printError {
  echo -e "\033[0m\033[31m[ERROR] $1\033[0m"
}

cleanup() {

    killall micro_ros_agent
    wait

    exit 0
}
trap cleanup SIGINT

echo ""
echo "################################################################"
echo "# BYU AGRICULTURAL ROBOTICS TEAM - STARTING THE AGROBOT SYSTEM #"
echo "################################################################"
echo ""

# Quick fix for daemon error (TODO: find a better solution)
source ~/ros2_ws/install/setup.bash
ros2 daemon stop
ros2 daemon start

# Start the micro-ROS agent
if [ -z "$(tycmd list | grep Teensy)" ]; then
    printError "No Teensy boards avaliable to connect to"
    echo ""

else 
    source ~/microros_ws/install/setup.bash
    ros2 run micro_ros_agent micro_ros_agent serial --dev /dev/ttyACM0 -b 6000000 &

    sleep 5
    echo ""
fi

# Start the ROS 2 launch files
source ~/ros2_ws/install/setup.bash
case $1 in
    "manual")
        ros2 launch cougars_control manual_launch.py
        ;;
    "moos")
        ros2 launch cougars_control moos_launch.py
        ;;
    "sensors")
        ros2 launch cougars_localization sensors_launch.py
        ;;
    *)
        printWarning "No start configuration specified"
        printWarning "Specify a start configuration using 'bash start.sh <config>' (ex. 'bash start.sh moos')"
        echo ""
        ;;
esac

cleanup
