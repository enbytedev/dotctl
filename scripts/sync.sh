#!/bin/bash

# Directories
SCRIPT_PATH=/usr/local/share/dotctl
BASE_DIR=~/.dotctl/base
INTERMEDIATE_DIR=~/.dotctl/intermediate
CHANGES_DIR=~/.dotctl/changes
PATCHES_DIR=$CHANGES_DIR/patches
ADDITIONS_DIR=$CHANGES_DIR/additions
DELETIONS_FILE=$CHANGES_DIR/deletions.txt
CONFIG_FILE=~/.dotctl/config.json

# Source the color functions
source $SCRIPT_PATH/print-functions.sh

print_blue 'This script will: '
print_dark_gray "- Overwrite all files inside $INTERMEDIATE_DIR"
print_dark_gray "- Replace them with the base dotfiles in this repository"
print_dark_gray "- Apply all patches inside $PATCHES_DIR to the intermediate directory"
print_dark_gray "- Inject all files from $ADDITIONS_DIR to the intermediate directory"
print_dark_gray "- Delete all files listed in $DELETIONS_FILE from the intermediate directory"

while true; do
    read -p "$(print_gray 'Do you want to continue? (y/N): ')" yn
    case $yn in
        [Yy]* ) print_blue "Syncing dotfiles..."; break;;
        [Nn]* | "" ) print_blue "Exiting script!"; exit;;
        * ) print_gray "Please answer yes (y) or no (N).";;
    esac
done

# Check if the base directory is a Git repository
if [ -d "$BASE_DIR/.git" ]; then
    print_debug "Checking for updates to the Git repository..."
    cd $BASE_DIR
    # Check if a remote repository is configured
    if git remote show origin > /dev/null 2>&1; then
        git remote update > /dev/null 2>&1

        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})
        BASE=$(git merge-base @ @{u})

        if [ $LOCAL = $REMOTE ]; then
            print_debug "The repository is up-to-date."
        elif [ $LOCAL = $BASE ]; then
            print_gray "Pulling updates from the remote repository..."
            git pull
        elif [ $REMOTE = $BASE ]; then
            print_red "Local repository has diverged from remote. Please resolve manually."
            exit 1
        else
            print_red "Local repository has diverged from remote. Please resolve manually."
            exit 1
        fi
    else
        print_debug "No remote repository configured. Proceeding with local repository."
    fi
    cd - > /dev/null
else
    print_debug "The base directory is not a Git repository. Skipping update check."
fi

# Clean intermediary directory
rm -rf $INTERMEDIATE_DIR
mkdir -p $INTERMEDIATE_DIR

# Copy base dotfiles to intermediary directory
cp -r $BASE_DIR/* $INTERMEDIATE_DIR

# Process patches
print_gray "Processing patches..."
if ls $PATCHES_DIR/*.patch 1> /dev/null 2>&1; then
  for patch in $PATCHES_DIR/*.patch; do
    # Determine the target file for the patch
    target_file=${patch##*/}
    target_file=${target_file//_/\/}
    target_file=$INTERMEDIATE_DIR/${target_file%.patch}

    # Apply the patch silently
    patch "$target_file" < "$patch" > /dev/null 2>&1
    print_yellow "\t* $target_file"
  done
else
  print_debug "No patch files found in $PATCHES_DIR; skipping"
fi

# Copy extra files from additions directory to intermediary directory
print_gray "Processing additions..."
if [ -d $ADDITIONS_DIR ]; then
  if find $ADDITIONS_DIR -type f | read; then
    cp -r $ADDITIONS_DIR/* $INTERMEDIATE_DIR
    find $ADDITIONS_DIR -type f | while read -r addition; do
      relative_path=${addition#$ADDITIONS_DIR/}
      print_green "\t+ $relative_path"
    done
  else
    print_debug "No additions found in $ADDITIONS_DIR; skipping"
  fi
else
  print_debug "No additions found in $ADDITIONS_DIR; skipping"
fi

# Process deletions
print_gray "Processing deletions..."
if [ -f $DELETIONS_FILE ]; then
  if [ -s $DELETIONS_FILE ]; then
    while read -r file; do
      rm -f "$INTERMEDIATE_DIR/$file"
      print_red "\t- $file"

      # Check if the directory is empty and remove it if it is
      dir=$(dirname "$INTERMEDIATE_DIR/$file")
      relative_dir=${dir#$INTERMEDIATE_DIR/}
      if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
        rmdir "$dir"
        print_red "\t- $relative_dir/"
      fi
    done < $DELETIONS_FILE
  else
    print_debug "No deletions found in $DELETIONS_FILE; skipping"
  fi
else
  print_debug "No deletions file found in $DELETIONS_FILE; skipping"
fi

print_debug "Preparing to link... "
# Read the JSON configuration before changing the directory
print_debug "\tApplying stow configurations from $CONFIG_FILE..."
CONFIG_ENTRIES=$(jq -r '.structure | to_entries[] | "\(.key) \(.value)"' $CONFIG_FILE)

cd $INTERMEDIATE_DIR

print_debug "Linked: "
# Use stow to create symlinks
echo "$CONFIG_ENTRIES" | while read -r folder target; do
  if [[ -d "$folder" ]]; then
    sudo stow --dotfiles -t "$target" -S "$folder"
    print_debug "\t$target"
  else
    print_debug "Folder $folder does not exist in $INTERMEDIATE_DIR"
  fi
done

print_blue "Sync complete!"
