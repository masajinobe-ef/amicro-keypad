#!/usr/bin/env bash

PORT=$(arduino-cli board list --format text | grep "arduino:avr:micro" | awk '{print $1}')
if [ -z "$PORT" ]; then
    echo "Arduino not found!"
    exit 1
fi

stty -F "$PORT" 9600 raw -echo
cat "$PORT"
