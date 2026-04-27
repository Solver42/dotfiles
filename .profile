export ENV="$HOME/.mkshrc"

if [ -z $DISPLAY ] && [ $(tty) = /dev/tty1 ]; then
    exec startx
fi
