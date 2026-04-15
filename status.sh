#!/bin/sh

# save terminal state
oldstty=$(stty -g)

# raw mode: no echo, instant keypress
stty -echo -icanon time 0 min 0

# hide cursor + clear screen ONCE
printf "\033[?25l\033[2J"

# restore on exit
cleanup() {
    stty "$oldstty"
    printf "\033[?25h\n"
    exit
}
trap cleanup INT TERM EXIT

while :; do
    out=""

    # move cursor to top (no clear)
    out="$out\033[H"

    # ---- TIME ----
    out="$out\n  ᛏ   $(date '+%H:%M:%S')\n"

    # ---- DATE ----
    out="$out  ᛞ   $(date '+%Y-%m-%d %a')\n"

    # ---- BATTERY ----
    bat_path="/sys/class/power_supply/BAT1"
    if [ -f "$bat_path/capacity" ]; then
        read -r bat < "$bat_path/capacity"
        read -r stat < "$bat_path/status"
        case "$stat" in
            Charging) s="+" ;;
            Discharging) s="-" ;;
            Full) s="~" ;;
            *) s="~" ;;
        esac
        out="$out  ᛖ   $bat $s\n"
    else
        out="$out  ᛖ   -\n"
    fi

    # ---- LOAD ----
    read one five fifteen _ < /proc/loadavg
    out="$out  ᛚ   $one $five $fifteen\n"

    # ---- MEMORY ----
    mem_total=0 mem_avail=0
    while read -r key val _; do
        case "$key" in
            MemTotal:) mem_total=$val ;;
            MemAvailable:) mem_avail=$val ;;
        esac
        [ "$mem_total" -ne 0 ] && [ "$mem_avail" -ne 0 ] && break
    done < /proc/meminfo

    used=$((mem_total - mem_avail))
    out="$out  ᛗ   $((used/1024/1024)).$(((used/1024/102)%10))G/$((mem_total/1024/1024)).$(((mem_total/1024/102)%10))G\n"

    # ---- DISK ----
    set -- $(df -h / 2>/dev/null | awk 'NR==2 {print $2, $3}')
    out="$out  ᛟ   $2/$1\n"

    # ---- NETWORK ----
    iface=""
    i=0
    while IFS=: read -r name _; do
        i=$((i + 1))
        [ "$i" -le 2 ] && continue
        name=${name#"${name%%[! ]*}"}
        [ "$name" = "lo" ] && continue
        iface=$name
        break
    done < /proc/net/dev

    ip=$(ip -4 addr show "$iface" 2>/dev/null)
    ip=${ip#*inet }
    ip=${ip%%/*}
    out="$out  ᚾ   ${ip:--}\n"

    # ---- WIFI ----
    rf=$(rfkill list wifi 2>/dev/null | awk '/Soft blocked:/ {print $3}')
    state=$(nmcli radio wifi 2>/dev/null)

    if [ "$rf" = "yes" ]; then wifi="-"
    elif [ "$state" != "enabled" ]; then wifi="~"
    else wifi="+"; fi

    out="$out  ᚹ   $wifi\n"

    # ---- BLUETOOTH ----
    rf=$(rfkill list bluetooth 2>/dev/null | awk '/Soft blocked:/ {print $3}')
    svc=$(systemctl is-active bluetooth.service 2>/dev/null)

    if [ "$rf" = "yes" ]; then bt="-"
    elif [ "$svc" != "active" ]; then bt="~"
    else bt="+"; fi

    out="$out  ᛒ   $bt\n"

    # ---- TEMP ----
    temp_file="/sys/class/thermal/thermal_zone0/temp"
    if [ -f "$temp_file" ]; then
        read -r t < "$temp_file"
        out="$out  ᚦ   $((t/1000))\n"
    else
        out="$out  ᚦ   -\n"
    fi

    # ---- VOLUME ----
    if command -v pamixer >/dev/null 2>&1; then
        vol=$(pamixer --get-volume 2>/dev/null)
        mute=$(pamixer --get-mute 2>/dev/null)
        [ "$mute" = "true" ] && mute=" (muted)" || mute=""
        # \033[K clears the rest of the line to prevent "ghost" characters
        out="$out  ᚨ   ${vol:--}$mute\033[K\n"
    else
        out="$out  ᚨ   -\033[K\n"
    fi

    # draw frame (atomic)
    printf "%b" "$out"

    # input at end (non-blocking)
    read -r -t 1 -n 1 key
    [ "$key" = "q" ] && break
done
