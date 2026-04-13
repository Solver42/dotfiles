#!/bin/sh

# move cursor to top (no flicker)
printf "\033[2J\033[H"

# ---- TIME ----
printf "\n  ᛏ   %s\n" "$(date '+%H:%M:%S')"

# ---- DATE ----
printf "  ᛞ   %s\n" "$(date '+%Y-%m-%d %a')"

# ---- BATTERY ----
bat_path="/sys/class/power_supply/BAT1"
if [ -f "$bat_path/capacity" ]; then
    read -r bat < "$bat_path/capacity"
    read -r stat < "$bat_path/status"

    case "$stat" in
        Charging)    s="+" ;;
        Discharging) s="-" ;;
        Full)        s="~" ;;
        *)           s="~" ;;
    esac

    printf "  ᛖ   %s %s\n" "$bat" "$s"
else
    printf "  ᛖ   -\n"
fi

# ---- CPU LOAD (no uptime) ----
read one five fifteen rest < /proc/loadavg
printf "  ᛚ   %s %s %s\n" "$one" "$five" "$fifteen"

# ---- MEMORY (no free) ----
mem_total=0
mem_avail=0
while read -r key val unit; do
    case "$key" in
        MemTotal:) mem_total=$val ;;
        MemAvailable:) mem_avail=$val ;;
    esac
    [ "$mem_total" -ne 0 ] && [ "$mem_avail" -ne 0 ] && break
done < /proc/meminfo
used=$((mem_total - mem_avail))
# GB with 1 decimal
total_gb=$((mem_total / 1024 / 1024))
total_dec=$(((mem_total / 1024 / 102) % 10))
used_gb=$((used / 1024 / 1024))
used_dec=$(((used / 1024 / 102) % 10))
printf "  ᛗ   %s.%sG/%s.%sG\n" "$used_gb" "$used_dec" "$total_gb" "$total_dec"

# ---- DISK ----
set -- $(df -h / 2>/dev/null | awk 'NR==2 {print $2, $3}')
total=$1
used=$2
printf "  ᛟ   %s/%s\n" "$used" "$total"

# ---- NETWORK ----
# get first UP interface
iface=""
# skip first 2 header lines explicitly
i=0
while IFS=: read -r name rest; do
    i=$((i + 1))
    [ "$i" -le 2 ] && continue
    # remove leading spaces
    name=${name#"${name%%[! ]*}"}
    case "$name" in
        lo) continue ;;
        *)
            iface=$name
            break
            ;;
    esac
done < /proc/net/dev
ip=$(ip -4 addr show "$iface" 2>/dev/null)
ip=${ip#*inet }
ip=${ip%%/*}
printf "  ᚾ   %s\n" "${ip:--}"

# ---- WIFI ----
rf=$(rfkill list wifi 2>/dev/null | awk '/Soft blocked:/ {print $3}')
state=$(nmcli radio wifi 2>/dev/null)

if [ "$rf" = "yes" ]; then
    wifi="-"
elif [ "$state" != "enabled" ]; then
    wifi="~"
else
    wifi="+"
fi

printf "  ᚹ   %s\n" "$wifi"

# ---- BLUETOOTH ----
rf=$(rfkill list bluetooth 2>/dev/null | awk '/Soft blocked:/ {print $3}')
svc=$(systemctl is-active bluetooth.service 2>/dev/null)
if [ "$rf" = "yes" ]; then
    bt="-"
elif [ "$svc" != "active" ]; then
    bt="~"
else
    bt="+"
fi
printf "  ᛒ   %s\n" "$bt"

# ---- TEMPERATURE ----
temp_file="/sys/class/thermal/thermal_zone0/temp"
if [ -f "$temp_file" ]; then
    read -r t < "$temp_file"
    t=$((t / 1000))
    printf "  ᚦ   %s\n" "$t"
else
    printf "  ᚦ   -\n"
fi

# ---- VOLUME (pamixer) ----
if command -v pamixer >/dev/null 2>&1; then
    vol=$(pamixer --get-volume 2>/dev/null)
    mute=$(pamixer --get-mute 2>/dev/null)
    [ "$mute" = "true" ] && mute=" (muted)" || mute=""
    printf "  ᚨ   %s%s\n" "${vol:--}" "$mute"
else
    printf "  ᚨ   -\n"
fi
printf "\n"
