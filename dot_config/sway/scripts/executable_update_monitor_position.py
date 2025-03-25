#!/usr/bin/env python3

import json
import subprocess
import sys
import math
import shutil

SCALE_TWEAK = 1.2

# Script arguments are:
# * the scale for the bottom monitor
# * the name of the bottom monitor
# * the scale for the top monitor
# * the list of top monitors
if len(sys.argv) < 3:
    print("Usage: script.py bottom_scale bottom_monitor [top_monitors...]")
    sys.exit(1)

bottom_scale = float(sys.argv[1])
bottom_monitor = sys.argv[2]
top_monitor_list = sys.argv[3:]

# Figure out whether we have an extra monitor
outputs_json = subprocess.check_output(["swaymsg", "--raw", "-t", "get_outputs"], text=True)
outputs = json.loads(outputs_json)

top_monitor = ""
for monitor in top_monitor_list:
    for output in outputs:
        if output.get("name") == monitor and output.get("active"):
            top_monitor = monitor
            break
    if top_monitor:
        break

if not top_monitor:
    subprocess.run(["swaymsg", f"output {bottom_monitor} scale {bottom_scale:.2f}"])
    sys.exit(1)

# Calculate the top monitor scale to match the bottom monitor
if not shutil.which("wlr-randr"):
    top_scale = bottom_scale
else:
    randr_json = subprocess.check_output(["wlr-randr", "--json"], text=True)
    randr = json.loads(randr_json)

    # Find top monitor information
    top_randr = None
    bottom_randr = None
    for monitor in randr:
        if monitor.get("name") == top_monitor:
            top_randr = monitor
        if monitor.get("name") == bottom_monitor:
            bottom_randr = monitor

    top_phys = top_randr.get("physical_size", {}).get("width")
    top_res = top_randr.get("modes", [{}])[0].get("width")
    top_dpi = top_res / top_phys

    bottom_phys = bottom_randr.get("physical_size", {}).get("width")
    bottom_res = bottom_randr.get("modes", [{}])[0].get("width")
    bottom_dpi = bottom_res / bottom_phys

    ratio = top_dpi / bottom_dpi
    top_scale = bottom_scale * ratio * SCALE_TWEAK

# Set the monitor scale
subprocess.run(["swaymsg", f"output {top_monitor} scale {top_scale:.2f}"])
subprocess.run(["swaymsg", f"output {bottom_monitor} scale {bottom_scale:.2f}"])

# Get updated outputs
outputs_json = subprocess.check_output(["swaymsg", "--raw", "-t", "get_outputs"], text=True)
outputs = json.loads(outputs_json)

# Get monitor sizes
top_info = None
bottom_info = None
for output in outputs:
    if output.get("name") == top_monitor:
        top_info = output
    if output.get("name") == bottom_monitor:
        bottom_info = output

top_width = top_info.get("rect", {}).get("width")
top_height = top_info.get("rect", {}).get("height")
bottom_width = bottom_info.get("rect", {}).get("width")
bottom_height = bottom_info.get("rect", {}).get("height")

# Set monitor positions
y = top_height
if bottom_width < top_width:
    x = math.floor((top_width - bottom_width) / 2)
    subprocess.run(["swaymsg", f"output {top_monitor} position 0 0"])
    subprocess.run(["swaymsg", f"output {bottom_monitor} position {x} {y}"])
else:
    x = math.floor((bottom_width - top_width) / 2)
    subprocess.run(["swaymsg", f"output {top_monitor} position {x} 0"])
    subprocess.run(["swaymsg", f"output {bottom_monitor} position 0 {y}"])
