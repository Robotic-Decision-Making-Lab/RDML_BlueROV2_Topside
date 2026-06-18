cmake_minimum_required(VERSION 3.24)
project(topside_description)

find_package(ament_cmake REQUIRED)

install(DIRECTORY config DESTINATION share/topside_description)

ament_package()
