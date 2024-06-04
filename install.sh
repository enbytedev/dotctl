#!/bin/bash

# Set format version
FORMAT_VERSION="1b"
# Read the version from the VERSION file
VERSION=$(cat "./VERSION")

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

print_blue "Installing dotctl..."

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Path to config.json
CONFIG_PATH="$HOME/.dotctl/config.json"

# Make sure the directories exist
print_gray "Creating directories..."
sudo mkdir -p /usr/local/share/dotctl
mkdir -p $HOME/.dotctl
mkdir -p $HOME/.dotctl/base
mkdir -p $HOME/.dotctl/intermediate
mkdir -p $HOME/.dotctl/patches

# Copy all scripts to /usr/local/share/dotctl
print_gray "Copying scripts..."
sudo cp -r $SCRIPT_DIR/scripts/* /usr/local/share/dotctl/

# Set execute permissions for all scripts in /usr/local/share/dotctl
sudo chmod +x /usr/local/share/dotctl/*.sh
# Set execute permissions for all scripts inside this repository folder.
sudo chmod +x ./*.sh

# Check if config.json exists, if not, create it with the template
print_gray "Checking for config.json..."
if [ ! -f "$CONFIG_PATH" ]; then
    cat <<EOL > "$CONFIG_PATH"
{
    "format_version": "$FORMAT_VERSION",
    "structure": {
        "home": "/home/tommy/",
        "dot-local": "/home/tommy/.local/",
        "dot-config": "/home/tommy/.config/",
        "etc": "/etc/",
        "usr": "/usr/"
    }
}
EOL
    print_gray "Created $CONFIG_PATH with default template."
fi

# Create the wrapper script
print_gray "Creating wrapper script..."
WRAPPER_SCRIPT_PATH="/usr/local/bin/dotctl"
sudo cp /usr/local/share/dotctl/dotctl-wrapper.sh $WRAPPER_SCRIPT_PATH

# Make the wrapper script executable
sudo chmod +x "$WRAPPER_SCRIPT_PATH"
print_gray "Wrapper script created at $WRAPPER_SCRIPT_PATH"

# Add version tag to all scripts
print_gray "Adding version tag to scripts..."
./add-version-tag.sh $VERSION

print_blue "Successfully installed dotctl!"
