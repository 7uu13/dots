#!/bin/bash

CONFIG_FILES="$HOME/.config/waybar/config $HOME/.config/waybar/style.css"
PID=""

# Function to restart waybar
restart_waybar() {
	if [ -n "$PID" ]; then
		kill -s SIGHUP "$PID" # Send SIGHUP to reload configuration
	else
		waybar & # Start waybar if not already running
		PID=$!   # Record PID of the process
	fi
}

# Trap and handle EXIT signal properly
cleanup() {
	kill -s SIGTERM "$PID" # Terminate waybar process on exit
	exit 0
}
trap cleanup EXIT

# Initial start of waybar
restart_waybar

# Monitor changes in configuration files
while true; do
	if inotifywait -e modify,create "$CONFIG_FILES"; then
		restart_waybar
		sleep 1 # Add a small delay to debounce multiple changes
	fi
done
