#!/bin/bash

SCRIPT_PATH=/usr/local/share/dotctl
source $SCRIPT_PATH/print-functions.sh

# Arguments
TAR_FILENAME=$1

# Directories
CHANGES_DIR=~/.dotctl/changes
EXPORT_DIR=~/.dotctl

# Check if the tar file name is provided
if [ -z "$TAR_FILENAME" ]; then
  echo "Usage: $0 <tar-filename>"
  exit 1
fi

# Ensure the filename has a .tar extension
if [[ $TAR_FILENAME != *.tar ]]; then
  TAR_FILENAME="${TAR_FILENAME}.tar"
fi

# Remove any existing tar file with the same name
rm -f $EXPORT_DIR/$TAR_FILENAME 

# Create a tar file containing the previous changes
tar -cf $EXPORT_DIR/$TAR_FILENAME -C $CHANGES_DIR additions patches deletions.txt 2>/dev/null || true

print_gray "Exported current changes: $EXPORT_DIR/$TAR_FILENAME"
