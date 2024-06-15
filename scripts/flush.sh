#!/bin/bash

SCRIPT_PATH=/usr/local/share/dotctl
source $SCRIPT_PATH/print-functions.sh

# Directories
CHANGES_DIR=~/.dotctl/changes
ADDITIONS_DIR=$CHANGES_DIR/additions
PATCHES_DIR=$CHANGES_DIR/patches
DELETIONS_FILE=$CHANGES_DIR/deletions.txt

# Function to flush a specific file or directory
flush_target() {
  local target="$1"
  local addition_path="$ADDITIONS_DIR/$target"
  local patch_path="$PATCHES_DIR/${target//\//_}.patch"
  local relative_path="$target"

  # Check if the target is in the additions directory
  if [ -e "$addition_path" ]; then
    rm -rf "$addition_path"
    print_gray "Flushed addition: $addition_path"
    return
  fi

  # Check if the target is a patch (modification)
  if [ -e "$patch_path" ]; then
    rm -f "$patch_path"
    print_gray "Flushed modification: $patch_path"
    return
  fi

  # Check if the target is in the deletions file
  if [ -e "$DELETIONS_FILE" ]; then
    if grep -q "$relative_path" "$DELETIONS_FILE"; then
      sed -i "\|$relative_path|d" "$DELETIONS_FILE"
      print_gray "Flushed deletion: $relative_path"
      return
    fi
  fi

  print_gray "Error: $target does not exist in $CHANGES_DIR"
}

# Function to flush all changes
flush_all() {
  rm -rf $CHANGES_DIR
  mkdir -p $CHANGES_DIR
  print_gray "Flushed all changes in: $CHANGES_DIR"
}

# Ask for confirmation
if [ -n "$1" ]; then
  read -p "Are you sure you want to flush $1? This will delete $1 from $CHANGES_DIR. (y/N): " confirm
else
  read -p "Are you sure you want to flush all changes? This will delete all contents in $CHANGES_DIR. (y/N): " confirm
fi
confirm=${confirm,,}  # tolower

if [[ "$confirm" != "y" ]]; then
  print_gray "Operation cancelled."
  exit 0
fi

# Check if a specific target is provided
if [ -n "$1" ]; then
  flush_target "$1"
else
  flush_all
fi

print_gray "Please sync again to revert to base."
