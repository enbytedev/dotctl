#!/bin/bash

# Directories
BASE_DIR=~/.dotctl/base

# Source the color functions
SCRIPT_PATH=/usr/local/share/dotctl
source $SCRIPT_PATH/print-functions.sh

print_blue "Initializing base directory..."

# Ask for the remote Git repository URL
read -p "$(print_gray 'Enter the remote Git repository URL (leave blank to initialize a local repository): ')" remote_repo

# Ensure the base directory exists
mkdir -p $BASE_DIR

# Get the user's name
USER_NAME=$(whoami)

# README.md template
readme_template=$(cat <<EOF
<p align="center">
  <a href="https://github.com/enbytedev/dotctl"><img src="https://raw.githubusercontent.com/enbytedev/dotctl/main/ICON.png" width="250" height="250" /></a>

<h2 align="center">$USER_NAME's dotfiles ✨</h2>
 <p align="center"><i>This repository is being managed with the help of <a href="https://github.com/enbytedev/dotctl">dotctl</a>.</i></p>
EOF
)

# Function to initialize a local Git repository
initialize_local_repo() {
    cd $BASE_DIR
    if [ -d ".git" ]; then
        print_gray "A local Git repository already exists in $BASE_DIR."
    else
        git init
        print_green "Initialized a local Git repository in $BASE_DIR."
        echo "$readme_template" > README.md
        git add README.md
        git commit -m "Add README.md"
        print_green "Created README.md and committed to local repository."
    fi
}

# Function to clone the remote Git repository
clone_remote_repo() {
    if git ls-remote "$remote_repo" &> /dev/null; then
        print_gray "A remote repository URL was provided. This will overwrite the contents of $BASE_DIR."
        while true; do
            read -p "$(print_gray 'Are you sure you want to continue? (y/N): ')" confirm
            confirm=${confirm,,}  # tolower
            case $confirm in
                [y]* )
                    rm -rf $BASE_DIR/*
                    git clone "$remote_repo" $BASE_DIR
                    print_green "Cloned remote repository into $BASE_DIR."
                    break
                    ;;
                [n]* | "" )
                    print_blue "Operation cancelled."
                    exit 0
                    ;;
                * )
                    print_gray "Please answer yes (y) or no (N)."
                    ;;
            esac
        done
    else
        print_red "Invalid remote repository URL. Please try again."
        exit 1
    fi
}

# Check if a remote repository URL was provided
if [ -z "$remote_repo" ]; then
    initialize_local_repo
else
    clone_remote_repo
fi

print_blue "Base directory initialization complete!"
