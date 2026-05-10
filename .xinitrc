setxkbmap se -option caps:backspace
xmodmap -e "clear Lock"

# reduce polling / wakeups
echo 1500 > /proc/sys/vm/dirty_writeback_centisecs

xset b off
xset r rate 250 60 &

export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
export XDG_CURRENT_DESKTOP=gtk
systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
/usr/lib/xdg-desktop-portal-gtk &
/usr/lib/xdg-desktop-portal &

xrandr --dpi 144 &
export GDK_SCALE=2
export GDK_DPI_SCALE=1.0
export QT_SCALE_FACTOR=1.0
export XCURSOR_SIZE=50


xrdb -merge ~/.Xresources &

picom &
exec dwm
