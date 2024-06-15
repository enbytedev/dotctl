#!/bin/bash

# Define ANSI escape codes for colored text
BLUE_BOLD='\033[1;34m'
GRAY='\033[0;37m'
DARK_GRAY='\033[0;90m'
GREEN='\033[0;32m'
RED='\033[1;91m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Function to check if debug logging is enabled in the config
is_debug_enabled() {
    local config_file="$HOME/.dotctl/config.json"
    local enable_debug=$(jq -r '.enableDebugLogging' "$config_file")
    if [ "$enable_debug" == "true" ]; then
        return 0  # Debug logging enabled
    else
        return 1  # Debug logging disabled
    fi
}

# Function to print debug message in dark gray if debug logging is enabled
print_debug() {
    local message="$1"
    if is_debug_enabled; then
        echo -e "${DARK_GRAY}${message}${RESET}"
    fi
}

print_gray() {
  local message=$1
  echo -e "${GRAY}${message}${RESET}"
}

print_dark_gray() {
  local message=$1
  echo -e "${DARK_GRAY}${message}${RESET}"
}

print_blue() {
  local message=$1
  echo -e "${BLUE_BOLD}${message}${RESET}"
}

print_green() {
  local message=$1
  echo -e "${GREEN}${message}${RESET}"
}

print_red() {
  local message=$1
  echo -e "${RED}${message}${RESET}"
}

print_yellow() {
  local message=$1
  echo -e "${YELLOW}${message}${RESET}"
}
