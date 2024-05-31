#!/bin/bash

SCRIPT_PATH=/usr/local/share/dotctl
source $SCRIPT_PATH/print-functions.sh

# Directories
BASE_DIR=~/.dotctl/base
INTERMEDIATE_DIR=~/.dotctl/intermediate
CHANGES_DIR=~/.dotctl/changes
ADDITIONS_DIR=$CHANGES_DIR/additions
PATCHES_DIR=$CHANGES_DIR/patches
DELETIONS_FILE=$CHANGES_DIR/deletions.txt
GEN_CHANGES_SCRIPT_PATH="$SCRIPT_PATH/gen-changes.sh"

# Ask for confirmation
read -p "Are you sure you want to merge changes? This will overwrite contents in $BASE_DIR with $INTERMEDIATE_DIR and delete files as necessary. (y/N): " confirm
confirm=${confirm,,}  # tolower

if [[ "$confirm" != "y" ]]; then
  echo "Operation cancelled."
  exit 0
fi

# Run generate-changes to track deletions and changes
if [ -f "$GEN_CHANGES_SCRIPT_PATH" ]; then
    print_blue "Running gen-changes..."
    "$GEN_CHANGES_SCRIPT_PATH"
else
    print_gray "Error: $GEN_CHANGES_SCRIPT_PATH does not exist."
    exit 1
fi

# Overwrite base with intermediate
print_blue "Merging..."
cp -r $INTERMEDIATE_DIR/* $BASE_DIR/

# Handle deletions
if [ -f $DELETIONS_FILE ]; then
    print_blue "Applying deletions..."
    while IFS= read -r file; do
        rm -f "$BASE_DIR/$file"
        print_red "\t- $file"
        
        # Remove empty directories if needed
        dir=$(dirname "$BASE_DIR/$file")
        while [ "$dir" != "$BASE_DIR" ] && [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; do
            rmdir "$dir"
            print_red "\t- $dir"
            dir=$(dirname "$dir")
        done
    done < $DELETIONS_FILE
fi


print_blue "Merged $INTERMEDIATE_DIR into $BASE_DIR."
print_dark_gray "Please run --gen-changes to generate changes that reflect the new base."
