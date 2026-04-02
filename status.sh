#!/bin/sh

# move cursor to top (no flicker)
reset

# ---- TIME ----
printf "\n  ⏲   %s\n" "$(date '+%H:%M:%S')"

# ---- DATE ----
printf "  𝄝   %s\n" "$(date '+%Y-%m-%d (%a)')"

# ---- BATTERY ----
bat_path="/sys/class/power_supply/BAT1"

if [ -f "$bat_path/capacity" ]; then
    read -r bat < "$bat_path/capacity"
    read -r stat < "$bat_path/status"
    printf "  ⌁   %s%% (%s)\n" "$bat" "$stat"
else
    printf "  ⌁   N/A\n"
fi

# ---- CPU LOAD (no uptime) ----
read one five fifteen rest < /proc/loadavg
printf "  ⚙   %s %s %s\n" "$one" "$five" "$fifteen"

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

printf "  ⚂   %s.%sG/%s.%sG\n" "$used_gb" "$used_dec" "$total_gb" "$total_dec"

# ---- DISK (minimal, still needs df fallback avoided) ----
disk_line=$(df -h / 2>/dev/null | sed -n '2p')
set -- $disk_line
used=$3
total=$2

printf "  🖫   %s/%s\n" "$used" "$total"

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

printf "  ᯤ   %s %s\n" "${iface:-?}" "${ip:-N/A}"

# ---- TEMPERATURE ----
temp_file="/sys/class/thermal/thermal_zone0/temp"
if [ -f "$temp_file" ]; then
    read -r t < "$temp_file"
    t=$((t / 1000))
    printf "  🌡   %s°C\n" "$t"
else
    printf "  🌡   N/A\n"
fi

# ---- VOLUME (pamixer) ----
if command -v pamixer >/dev/null 2>&1; then
    vol=$(pamixer --get-volume 2>/dev/null)
    mute=$(pamixer --get-mute 2>/dev/null)
    [ "$mute" = "true" ] && mute=" (muted)" || mute=""
    printf "  🕨   %s%%%s\n" "${vol:-N/A}" "$mute"
else
    printf "  🕨   N/A\n"
fi
printf "\n"
