#!/usr/bin/env bash
# CPU usage sparkline for i3blocks (interval=persist, format=json)
# Draws the last $WIDTH one-second samples and colours the block by current load.

WIDTH=${WIDTH:-12}
bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
hist=()

read -r _ u n s i w q sq st _ < /proc/stat
prev_total=$((u + n + s + i + w + q + sq + st))
prev_idle=$((i + w))

while sleep 1; do
    read -r _ u n s i w q sq st _ < /proc/stat
    total=$((u + n + s + i + w + q + sq + st))
    idle=$((i + w))
    dt=$((total - prev_total))
    di=$((idle - prev_idle))
    prev_total=$total
    prev_idle=$idle
    ((dt > 0)) || continue

    pct=$((100 * (dt - di) / dt))
    hist+=("${bars[pct * 7 / 100]}")
    ((${#hist[@]} > WIDTH)) && hist=("${hist[@]:1}")

    if ((pct >= 80)); then
        color="#f7768e"
    elif ((pct >= 50)); then
        color="#e0af68"
    else
        color="#7aa2f7"
    fi

    graph=$(printf '%s' "${hist[@]}")
    printf '{"full_text":"%s %s %3d%%","color":"%s"}\n' "$LABEL" "$graph" "$pct" "$color"
done
