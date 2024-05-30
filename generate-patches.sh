#!/bin/bash

# Directories
BASE_DIR=~/.dotctl/base
INTERMEDIATE_DIR=~/.dotctl/intermediate
PATCH_DIR=~/.dotctl/patches

# Define ANSI escape codes for bright blue color and bold text
BLUE_BOLD='\033[1;34m'
GRAY='\033[0;37m'
RESET='\033[0m' # Reset color and formatting

print_gray() {
  local message=$1
  echo -e "${GRAY}${message}${RESET}"
}

print_blue() {
  local message=$1
  echo -e "${BLUE_BOLD}${message}${RESET}"
}

# Ensure patch directory exists
mkdir -p $PATCH_DIR

# Clean up old patch.tmp files
print_gray "Deleting old .patch.tmp files..."
find $PATCH_DIR -type f -name "*.patch.tmp" -exec rm {} \;

# Rename existing .patch files to .patch.tmp
print_gray "Renaming existing .patch files to .patch.tmp..."
find $PATCH_DIR -type f -name "*.patch" -exec bash -c 'mv "$0" "${0%.patch}.patch.tmp"' {} \;

# Function to generate patch for a single file
generate_patch() {
    local base_file=$1
    local intermediate_file=$2
    local relative_path=$3
    local patch_file=$4

    # Check if files are different and generate patch if they are
    if ! diff -u "$base_file" "$intermediate_file" > "$patch_file"; then
        print_blue "Patch created for $relative_path"
    else
        # Remove empty patch file if no differences
        rm "$patch_file"
    fi
}

# Export function for subshells
export -f generate_patch

# Find all files in the intermediary directory and generate patches
print_gray "Generating new patch files..."
find $INTERMEDIATE_DIR -type f | while read -r intermediate_file; do
    relative_path=${intermediate_file#$INTERMEDIATE_DIR/}
    base_file="$BASE_DIR/$relative_path"
    patch_file="$PATCH_DIR/${relative_path//\//_}.patch"

    # Generate patch if the base file exists and is different
    if [[ -f $base_file ]]; then
        generate_patch "$base_file" "$intermediate_file" "$relative_path" "$patch_file"
    fi
done

print_blue "Finished generating patch files!"
print_gray "Please remember to back up your patch files. To prevent data loss, a .tmp extension has been added to the previous patch files. These will be deleted next time this script is run."