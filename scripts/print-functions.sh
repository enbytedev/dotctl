#!/bin/bash

# Define ANSI escape codes for colored text
BLUE_BOLD='\033[1;34m'
GRAY='\033[0;37m'
DARK_GRAY='\033[0;90m'
GREEN='\033[0;32m'
RED='\033[1;91m'
YELLOW='\033[1;33m'
RESET='\033[0m'

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
