#!/bin/bash

SCRIPT_PATH=/usr/local/share/dotctl
source $SCRIPT_PATH/print-functions.sh

# Directories
CHANGES_DIR=~/.dotctl/changes

# Ask for confirmation
read -p "Are you sure you want to flush changes? This will delete all contents in $CHANGES_DIR. (y/N): " confirm
confirm=${confirm,,}  # tolower

if [[ "$confirm" != "y" ]]; then
  echo "Operation cancelled."
  exit 0
fi

# Remove the contents of changes directory and recreate it
rm -rf $CHANGES_DIR
mkdir -p $CHANGES_DIR

print_gray "Flushed changes in: $CHANGES_DIR; please sync again to revert to base."
