cmake_minimum_required(VERSION 3.24)
project(topside_bringup)

find_package(ament_cmake REQUIRED)

install(DIRECTORY launch DESTINATION share/topside_bringup)

ament_package()
