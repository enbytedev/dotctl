#!/bin/bash

SCRIPT_PATH=/usr/local/share/dotctl
source $SCRIPT_PATH/print-functions.sh

# Arguments
TAR_FILENAME=$1

# Directories
CHANGES_DIR=~/.dotctl/changes
mkdir $CHANGES_DIR

# Check if the tar file name is provided
if [ -z "$TAR_FILENAME" ]; then
  echo "Usage: $0 <tar-filename>"
  exit 1
fi

# Ensure the filename has a .tar extension
if [[ $TAR_FILENAME != *.tar ]]; then
  TAR_FILENAME="${TAR_FILENAME}.tar"
fi

# Determine the full path of the tar file
if [[ "$TAR_FILENAME" == */* ]]; then
  FULL_PATH=$TAR_FILENAME
else
  FULL_PATH=~/.dotctl/$TAR_FILENAME
fi

# Check if the tar file exists
if [ ! -f "$FULL_PATH" ]; then
  echo "Error: $FULL_PATH does not exist."
  exit 1
fi

# Remove existing contents of the changes directory
rm -rf $CHANGES_DIR/*

# Extract the tar file to the changes directory
tar -xf $FULL_PATH -C $CHANGES_DIR

print_gray "Imported changes from: $FULL_PATH"
