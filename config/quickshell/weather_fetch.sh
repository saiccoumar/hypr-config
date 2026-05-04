#!/bin/sh
res=$(curl -s -m 5 "wttr.in/?format=1" || echo "Error")
if echo "$res" | grep -qi "unknown\|error\|html\|sorry"; then
    echo "Weather data not available"
else
    echo "$res"
fi
