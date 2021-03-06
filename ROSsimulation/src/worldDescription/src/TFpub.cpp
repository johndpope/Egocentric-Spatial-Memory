/*
 * MoveUAV.cpp
 *
 *  Created on: 11 Oct, 2014
 *      Author: lin
 */

#include<ros/ros.h>
#include <gazebo_msgs/SetModelState.h>
#include<tf/transform_broadcaster.h>
#include "sensor_msgs/LaserScan.h"
#include <sensor_msgs/JointState.h>
#include <visualization_msgs/Marker.h>
#include <std_msgs/Float64.h>
#include "std_msgs/Float32MultiArray.h"
#include <visualization_msgs/Marker.h>

#include <stdio.h>
#include <vector>
#include <stdlib.h>
#include <iostream>
#include <fstream>

#define MOTION_UPDATE_RATE 50

using namespace std;

double R_yaw = 0;
double R_x = 0;
double R_y = 0;
double R_alti = 0;

ros::Subscriber tf_sub; // subscriber to the robot's pose topic
void PoseCallback(const std_msgs::Float32MultiArray::ConstPtr& array);

int main(int argc, char** argv)
{

	//ROS stuff
	ros::init(argc, argv, "TFpub");
	ros::NodeHandle n;

	ros::Subscriber tf_sub = n.subscribe("GlobalPose", 1, PoseCallback);
	//tf publisher
	tf::TransformBroadcaster tf_broadcaster_world;
	geometry_msgs::TransformStamped world_tf;
	world_tf.header.frame_id = "world";
	world_tf.child_frame_id = "body";

	ros::Rate rate(MOTION_UPDATE_RATE);

	//Heave Motion
	ROS_INFO("MOVE IT!");

        

	//Start moving
	while(ros::ok())
	{

		//Deal with TF
		world_tf.header.stamp = ros::Time::now();
		world_tf.transform.translation.x = R_x;
		world_tf.transform.translation.y = R_y;
		world_tf.transform.translation.z = R_alti;
		world_tf.transform.rotation = tf::createQuaternionMsgFromYaw(R_yaw);
		tf_broadcaster_world.sendTransform(world_tf);

		ros::spinOnce();
		rate.sleep();


	}


	ROS_INFO("Exit! Process Completed!");

	return 1; //end of main program
}


void PoseCallback(const std_msgs::Float32MultiArray::ConstPtr& array)
{

	R_x = array->data[0];
	R_y = array->data[1];
	R_alti = array->data[2];
	R_yaw = array->data[3];

	//cout<< R_x <<endl;
	//cout<< R_y <<endl;
	//cout<< R_alti <<endl;
	//cout<< R_yaw <<endl;

return;
}
