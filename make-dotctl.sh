#!/bin/bash

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

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Path to sync_config.json
CONFIG_PATH="$HOME/.dotctl/sync_config.json"

# Make sure the directories exist
mkdir -p $HOME/.dotctl
mkdir -p $HOME/.dotctl/base
mkdir -p $HOME/.dotctl/intermediate
mkdir -p $HOME/.dotctl/patches

cp $SCRIPT_DIR/sync-dots.sh $HOME/.dotctl/sync-dots.sh
cp $SCRIPT_DIR/generate-patches.sh $HOME/.dotctl/generate-patches.sh

# Check if sync_config.json exists, if not, create it with the template
if [ ! -f "$CONFIG_PATH" ]; then
    cat <<EOL > "$CONFIG_PATH"
{
    "home": "/home/tommy/",
    "dot-local": "/home/tommy/.local/",
    "dot-config": "/home/tommy/.config/",
    "etc": "/etc/",
    "usr": "/usr/"
}
EOL
    print_blue "Created $CONFIG_PATH with default template."
fi

# Define the wrapper script content
WRAPPER_SCRIPT_CONTENT="#!/bin/bash

# Path to the scripts and config file
SYNC_SCRIPT_PATH=\"$HOME/.dotctl/sync-dots.sh\"
PATCHES_SCRIPT_PATH=\"$HOME/.dotctl/generate-patches.sh\"
CONFIG_PATH=\"$HOME/.dotctl/sync_config.json\"
INTERMEDIATE_DIR=\"$HOME/.dotctl/intermediate\"
PATCHES_DIR=\"$HOME/.dotctl/patches\"
BASE_DIR=\"$HOME/.dotctl/base\"

# Function to display help menu
show_help() {
    echo \"Usage: dotctl [OPTION]\"
    echo \"Options:\"
    echo \"  --help, -h                   Display this help menu\"
    echo \"  --sync, -s                   Run the sync-dots.sh script\"
    echo \"  --gen-patches, -p            Run the generate-patches.sh script\"
    echo \"  --config, -c                 Open sync_config.json in nano\"
    echo \"  --intermediate-dir, -id      Open ~/.dotctl/intermediate in the file manager\"
    echo \"  --patches-dir, -pd           Open ~/.dotctl/patches in the file manager\"
    echo \"  --base-dir, -bd               Open ~/.dotctl/base in the file manager\"
}

# Parse command line arguments
case \"\$1\" in
    --help|-h)
        show_help
        ;;
    --sync|-s)
        if [ -f \"\$SYNC_SCRIPT_PATH\" ]; then
            chmod +x \"\$SYNC_SCRIPT_PATH\"
            \"\$SYNC_SCRIPT_PATH\"
        else
            echo \"Error: \$SYNC_SCRIPT_PATH does not exist.\"
            exit 1
        fi
        ;;
    --gen-patches|-p)
        if [ -f \"\$PATCHES_SCRIPT_PATH\" ]; then
            chmod +x \"\$PATCHES_SCRIPT_PATH\"
            \"\$PATCHES_SCRIPT_PATH\"
        else
            echo \"Error: \$PATCHES_SCRIPT_PATH does not exist.\"
            exit 1
        fi
        ;;
    --config|-c)
        if [ -f \"\$CONFIG_PATH\" ]; then
            nano \"\$CONFIG_PATH\"
        else
            echo \"Error: \$CONFIG_PATH does not exist.\"
            exit 1
        fi
        ;;
    --intermediate-dir|-id)
        if [ -d \"\$INTERMEDIATE_DIR\" ]; then
            xdg-open \"\$INTERMEDIATE_DIR\"
        else
            echo \"Error: \$INTERMEDIATE_DIR does not exist.\"
            exit 1
        fi
        ;;
    --patches-dir|-pd)
        if [ -d \"\$PATCHES_DIR\" ]; then
            xdg-open \"\$PATCHES_DIR\"
        else
            echo \"Error: \$PATCHES_DIR does not exist.\"
            exit 1
        fi
        ;;
    --base-dir|-bd)
        if [ -d \"\$BASE_DIR\" ]; then
            xdg-open \"\$BASE_DIR\"
        else
            echo \"Error: \$BASE_DIR does not exist.\"
            exit 1
        fi
        ;;
    *)
        echo \"Invalid option: \$1\"
        show_help
        exit 1
        ;;
esac
"

# Path to the wrapper script in /usr/local/bin
WRAPPER_SCRIPT_PATH="/usr/local/bin/dotctl"

# Create the wrapper script
echo "$WRAPPER_SCRIPT_CONTENT" | sudo tee "$WRAPPER_SCRIPT_PATH" > /dev/null

# Make the wrapper script executable
sudo chmod +x "$WRAPPER_SCRIPT_PATH"

echo "Wrapper script created at $WRAPPER_SCRIPT_PATH"
