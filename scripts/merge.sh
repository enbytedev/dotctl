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

# Check if a specific file or folder is provided as an argument
TARGET=$1

merge_all() {
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

    # Handle deletions for all files
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
}

merge_target() {
    local target=$1

    # Check if the target exists in the intermediate directory or is listed for deletion
    if [ ! -e "$INTERMEDIATE_DIR/$target" ] && ! grep -q "^$target\$" "$DELETIONS_FILE"; then
        print_red "Error: $INTERMEDIATE_DIR/$target does not exist and is not listed for deletion."
        exit 1
    fi

    # Run generate-changes to track deletions and changes
    if [ -f "$GEN_CHANGES_SCRIPT_PATH" ]; then
        print_blue "Running gen-changes..."
        print_red "Important: This will show all differences between base and intermediate. Only the target will be merged!"
        "$GEN_CHANGES_SCRIPT_PATH"
    else
        print_gray "Error: $GEN_CHANGES_SCRIPT_PATH does not exist."
        exit 1
    fi

    # Overwrite the specific target from intermediate to base if it exists
    print_blue "Merging $target..."
    if [ -d "$INTERMEDIATE_DIR/$target" ]; then
        cp -r "$INTERMEDIATE_DIR/$target/"* "$BASE_DIR/$target/"
    elif [ -f "$INTERMEDIATE_DIR/$target" ]; then
        cp "$INTERMEDIATE_DIR/$target" "$BASE_DIR/$target"
    fi

    # Handle deletions for the specific file or folder
    if [ -f $DELETIONS_FILE ]; then
        print_blue "Applying deletions..."
        while IFS= read -r file; do
            if [[ $file == $target* ]]; then
                rm -f "$BASE_DIR/$file"
                print_red "\t- $file"
                
                # Remove empty directories if needed
                dir=$(dirname "$BASE_DIR/$file")
                while [ "$dir" != "$BASE_DIR" ] && [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; do
                    rmdir "$dir"
                    print_red "\t- $dir"
                    dir=$(dirname "$dir")
                done
            fi
        done < $DELETIONS_FILE
    fi

    print_blue "Merged $INTERMEDIATE_DIR/$target into $BASE_DIR/$target."
}

if [ -n "$TARGET" ]; then
    # Ask for confirmation for specific file or folder
    read -p "Are you sure you want to merge $TARGET? This will overwrite $BASE_DIR/$TARGET with $INTERMEDIATE_DIR/$TARGET and delete files as necessary. (y/N): " confirm
    confirm=${confirm,,}  # tolower

    if [[ "$confirm" != "y" ]]; then
        echo "Operation cancelled."
        exit 0
    fi

    merge_target "$TARGET"
else
    # Ask for confirmation for all changes
    read -p "Are you sure you want to merge all changes? This will overwrite contents in $BASE_DIR with $INTERMEDIATE_DIR and delete files as necessary. (y/N): " confirm
    confirm=${confirm,,}  # tolower

    if [[ "$confirm" != "y" ]]; then
        echo "Operation cancelled."
        exit 0
    fi

    merge_all
fi

if [ -n "$TARGET" ]; then
    LOG_TARGET=" $1"
else
    LOG_TARGET=""
fi
print_dark_gray "Please run \"--flush$LOG_TARGET\" and \"--gen-changes\" to generate changes that reflect the new base."
