#!/bin/bash

# Directories
BASE_DIR=~/.dotctl/base
INTERMEDIATE_DIR=~/.dotctl/intermediate
PATCH_DIR=~/.dotctl/patches
CONFIG_FILE=~/.dotctl/sync_config.json

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

print_blue 'This script will: '
print_gray "- Overwrite all files inside $INTERMEDIATE_DIR\n- Replace them with the base_dotfiles in this repository\n- Apply all patches inside $PATCH_DIR to the intermediate directory"
print_gray "Please be sure you've installed 'stow' and 'jq'!"

while true; do
    read -p "$(print_gray 'Do you want to continue? (y/N): ')" yn
    case $yn in
        [Yy]* ) print_blue "Syncing dotfiles!"; break;;
        [Nn]* | "" ) print_blue "Exiting script!"; exit;;
        * ) print_gray "Please answer yes (y) or no (N).";;
    esac
done


# Clean intermediary directory
rm -rf $INTERMEDIATE_DIR
mkdir -p $INTERMEDIATE_DIR

# Copy base dotfiles to intermediary directory
cp -r $BASE_DIR/* $INTERMEDIATE_DIR

# Apply patches for sensitive information
if ls $PATCH_DIR/*.patch 1> /dev/null 2>&1; then
  for patch in $PATCH_DIR/*.patch; do
    # Determine the target file for the patch
    target_file=${patch##*/}
    target_file=${target_file//_/\/}
    target_file=$INTERMEDIATE_DIR/${target_file%.patch}

    # Apply the patch
    patch "$target_file" < "$patch"
  done
else
  print_gray "No patch files found in $PATCH_DIR"
fi

# Read the JSON configuration before changing the directory
print_gray "Applying stow configurations from $CONFIG_FILE..."
CONFIG_ENTRIES=$(jq -r 'to_entries[] | "\(.key) \(.value)"' $CONFIG_FILE)

cd $INTERMEDIATE_DIR

# Use stow to create symlinks
echo "$CONFIG_ENTRIES" | while read -r folder target; do
  if [[ -d "$folder" ]]; then
    sudo stow --dotfiles -t "$target" -S "$folder"
    print_gray "+ $target"
  else
    print_gray "Folder $folder does not exist in $INTERMEDIATE_DIR"
  fi
done
