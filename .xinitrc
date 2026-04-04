setxkbmap se &

# reduce polling / wakeups
echo 1500 > /proc/sys/vm/dirty_writeback_centisecs

xset b off
xset r rate 250 60 &

#xrandr --dpi 144 &
#export GDK_SCALE=2
#export GDK_DPI_SCALE=0.5
#export QT_SCALE_FACTOR=1.5
#export XCURSOR_SIZE=32

xrdb -merge ~/.Xresources &

picom &
exec dwm
