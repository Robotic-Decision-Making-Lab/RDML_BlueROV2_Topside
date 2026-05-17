# Copyright 2026, Evan Palmer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import importlib
from functools import reduce
from typing import Any

import rclpy
from rclpy.node import Node
from rclpy.qos import qos_profile_system_default as qos
from sensor_msgs.msg import Joy
from std_srvs.srv import SetBool


def rescale(value: float, min_val: float, max_val: float) -> float:
    return (((value + 1) * (max_val - min_val)) / 2.0) + min_val


def get_interface_type(type_name: str, interface_type: str):
    split_name = type_name.split("/")
    assert len(split_name) == 3, f"Invalid type_name '{type_name}'."
    package, interface, message = split_name
    if interface != interface_type:
        raise ValueError(f"Cannot use interface '{interface}' for an {interface_type}")
    module = importlib.import_module(package + "." + interface_type)
    return getattr(module, message)


def rgetattr(obj, attr, *args):
    def _getattr(obj, attr):
        return getattr(obj, attr, *args)

    return reduce(_getattr, [obj] + attr.split("."))


def rsetattr(obj, attr, val):
    pre, _, post = attr.rpartition(".")
    return setattr(rgetattr(obj, pre) if pre else obj, post, val)


class TeleOpInterface(Node):
    def __init__(self):
        super().__init__("topside_teleop")

        self.param_listener = teleop_interface.ParamListener(self)
        self.params = self.param_listener.get_params()

        self.rc_pub = self.create_publisher(OverrideRCIn, "/mavros/rc/override", qos)
        self.joy_sub = self.create_subscription(Joy, "/joy", self.rc_input_cb, qos)
        self.enable_srv = self.create_service(SetBool, "~/enable", self.enable_cb)

        control_params = self.params.external_control
        if control_params.enable:
            self.external_interface = get_interface_type(
                control_params.interface_type, "msg"
            )
