#!/bin/sh

# Script arguments are:
# * the scale for the bottom monitor
# * the name of the bottom monitor
# * the scale for the top monitor
# * the list of top monitors
BOTTOM_SCALE="$1"
BOTTOM_MONITOR="$2"
TOP_SCALE="$3"
shift 3
TOP_MONITOR_LIST="$@"

# Figure out whether we have an extra monitor.
OUTPUTS=$(swaymsg --raw -t get_outputs)
TOP_MONITOR=""
for MONITOR in $TOP_MONITOR_LIST; do
    if jq -e ".[] | select(.name == \"$MONITOR\" and .active == true)" <<< $OUTPUTS > /dev/null; then
        TOP_MONITOR="$MONITOR"
        break
    fi
done
if [ -z "$TOP_MONITOR" ]; then
    exit 1
fi

# Set the monitor scale.
swaymsg "output $TOP_MONITOR scale $TOP_SCALE"
swaymsg "output $BOTTOM_MONITOR scale $BOTTOM_SCALE"

# Get monitor sizes.
TOP_INFO=$(jq -r ".[] | select(.name == \"$TOP_MONITOR\")" <<< $OUTPUTS)
TOP_WIDTH=$(jq -r ".rect.width" <<< $TOP_INFO)
TOP_HEIGHT=$(jq -r ".rect.height" <<< $TOP_INFO)
BOTTOM_INFO=$(jq -r ".[] | select(.name == \"$BOTTOM_MONITOR\")" <<< $OUTPUTS)
BOTTOM_WIDTH=$(jq -r ".rect.width" <<< $BOTTOM_INFO)
BOTTOM_HEIGHT=$(jq -r ".rect.height" <<< $BOTTOM_INFO)
echo "Top monitor $TOP_MONITOR is $TOP_WIDTH x $TOP_HEIGHT"
echo "Bottom monitor $BOTTOM_MONITOR is $BOTTOM_WIDTH x $BOTTOM_HEIGHT"

# Set monitor positions.
Y=$TOP_HEIGHT
if [ "$BOTTOM_WIDTH" -lt "$TOP_WIDTH" ]; then
    X=$(awk "BEGIN {printf \"%.0f\", ($TOP_WIDTH - $BOTTOM_WIDTH) / 2}")
    swaymsg "output $TOP_MONITOR position 0 0"
    swaymsg "output $BOTTOM_MONITOR position $X $Y"
else
    X=$(awk "BEGIN {printf \"%.0f\", ($BOTTOM_WIDTH - $TOP_WIDTH) / 2}")
    swaymsg "output $TOP_MONITOR position $X 0"
    swaymsg "output $BOTTOM_MONITOR position 0 $Y"
fi
