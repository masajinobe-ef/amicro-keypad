#!/usr/bin/env bash
set -eo pipefail

SKETCH_DIR="./src/keypad"
SKETCH_FILE="keypad.ino"
FQBN="arduino:avr:micro"
BUILD_DIR="./build"
OUTPUT_DIR="./output"
LIB_DIR="./libs"

check_dependencies() {
    echo "🔍 Checking dependencies..."
    dependencies=("arduino-cli" "grep" "awk" "sudo")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "❌ Dependency '$dep' is not installed. Please install it."
            exit 1
        fi
    done
    echo "✔ All dependencies are installed."
}

find_port() {
    PORT=$(arduino-cli board list --format text | grep "$FQBN" | awk '{print $1}')
    if [ -z "$PORT" ]; then
        echo "❌ Arduino Micro not found!"
        echo "Please check:"
        echo "1. USB cable connection"
        echo "2. Power indicator on the board"
        exit 1
    fi
    echo "✔ Port: $PORT"

    if [ ! -w "$PORT" ]; then
        echo "🔒 Setting permissions on the port..."
        sudo chmod a+rw "$PORT" || {
            echo "❌ Failed to set permissions. Run:"
            echo "sudo usermod -aG dialout $USER && sudo chmod a+rw $PORT"
            exit 1
        }
    fi
}

compile_sketch() {
    echo "🔨 Compiling (FQBN: $FQBN)..."
    if ! arduino-cli compile \
        -b "$FQBN" \
        --build-path "$BUILD_DIR" \
        --output-dir "$OUTPUT_DIR" \
        --libraries "$LIB_DIR" \
        --warnings all \
        "$SKETCH_DIR"; then

        echo "❌ Compilation error!"
        echo "Check for errors or warnings in the output above."
        exit 1
    fi
}

upload_sketch() {
    echo "🚀 Uploading to $PORT..."
    if ! arduino-cli upload \
        -b "$FQBN" \
        -p "$PORT" \
        --input-dir "$OUTPUT_DIR"; then

        echo "❌ Upload error!"
        echo "Check for errors in the output above."
        exit 1
    fi
}

main() {
    check_dependencies
    find_port
    compile_sketch
    upload_sketch
    echo "✅ Success! Sketch '$SKETCH_FILE' activated."
    echo "⚠️ For HID devices, you may need to reconnect."
}

main
