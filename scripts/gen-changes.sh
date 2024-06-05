#!/bin/bash

# Directories
SCRIPT_PATH=/usr/local/share/dotctl
BASE_DIR=~/.dotctl/base
INTERMEDIATE_DIR=~/.dotctl/intermediate
CHANGES_DIR=~/.dotctl/changes
PATCHES_DIR=$CHANGES_DIR/patches
ADDITIONS_DIR=$CHANGES_DIR/additions
DELETIONS_FILE=$CHANGES_DIR/deletions.txt

source $SCRIPT_PATH/print-functions.sh
PACKAGE_CHANGES_SCRIPT=$SCRIPT_PATH/export.sh

print_blue "Generating changes..."

# Backup previous changes
$PACKAGE_CHANGES_SCRIPT old-changes.tar

# Ensure directory exists
mkdir -p $CHANGES_DIR

# Clean up old patches, additions, and deletions
print_debug "Regenerating fresh patches directory..."
rm -rf $PATCHES_DIR
mkdir -p $PATCHES_DIR

print_debug "Regenerating fresh additions directory..."
rm -rf $ADDITIONS_DIR
mkdir -p $ADDITIONS_DIR

print_debug "Removing stale deletions file..."
rm -f $DELETIONS_FILE

# Generate patch for each modified file
generate_patch() {
    local base_file=$1
    local intermediate_file=$2
    local relative_path=$3
    local patch_file=$4

    # Check if files are different and generate patch if they are
    if ! diff -u "$base_file" "$intermediate_file" > "$patch_file"; then
        print_yellow "\t* $relative_path"
    else
        # Remove empty patch file if no differences
        rm "$patch_file"
    fi
}

# Export function for subshells
export -f generate_patch

# Identify additions and copy to additions directory
print_gray "Identifying additions..."
find $INTERMEDIATE_DIR -type f | while read -r intermediate_file; do
    # Skip files in the .git directory
    if [[ "$intermediate_file" == *"/.git/"* ]]; then
        continue
    fi

    relative_path=${intermediate_file#$INTERMEDIATE_DIR/}
    base_file="$BASE_DIR/$relative_path"
    patch_file="$PATCHES_DIR/${relative_path//\//_}.patch"

    # Check if the file is an addition
    if [[ ! -f $base_file ]]; then
        # Copy the extra files to the additions directory
        additions_target="$ADDITIONS_DIR/$relative_path"
        mkdir -p "$(dirname "$additions_target")"
        cp "$intermediate_file" "$additions_target"
        print_green "\t+ $relative_path"
    fi
done

# Identify changes and generate patches
print_gray "Identifying changes..."
find $INTERMEDIATE_DIR -type f | while read -r intermediate_file; do
    # Skip files in the .git directory
    if [[ "$intermediate_file" == *"/.git/"* ]]; then
        continue
    fi

    relative_path=${intermediate_file#$INTERMEDIATE_DIR/}
    base_file="$BASE_DIR/$relative_path"
    patch_file="$PATCHES_DIR/${relative_path//\//_}.patch"

    # Generate patch if the base file exists and is different
    if [[ -f $base_file ]]; then
        generate_patch "$base_file" "$intermediate_file" "$relative_path" "$patch_file"
    fi
done

# Identify deletions
print_gray "Identifying deletions..."
find $BASE_DIR -type f | while read -r base_file; do
    # Skip files in the .git directory
    if [[ "$base_file" == *"/.git/"* ]]; then
        continue
    fi

    relative_path=${base_file#$BASE_DIR/}
    intermediate_file="$INTERMEDIATE_DIR/$relative_path"

    # If the file is in BASE_DIR but not in INTERMEDIATE_DIR, mark it as a deletion
    if [[ ! -f $intermediate_file ]]; then
        echo "$relative_path" >> $DELETIONS_FILE
        print_red "\t- $relative_path"
    fi
done

print_blue "Finished generating change files!"