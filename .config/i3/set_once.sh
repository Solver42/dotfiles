#!/bin/sh

# Enable natural scrolling
xinput set-prop "MSFT0004:00 06CB:CD98 Touchpad" "libinput Natural Scrolling Enabled" 1

# Set key repeat rate
xset r rate 200 50

# Disable bell
xset b off

picom
xinput list
udiskie &

