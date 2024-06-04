#!/bin/bash
#
# The format version reflects the file structure and defaults within the config.json
# This script will automatically handle updating old format versions as things may change.
#
###
CONFIG_PATH="$HOME/.dotctl/config.json"
BACKUP_PATH="$HOME/.dotctl/.config_backup.json"

# Function to perform a backup
backup_file() {
    local file_path="$1"
    local backup_path="$2"
    cp "$file_path" "$backup_path"
    echo "Backup of $(basename "$file_path") created at $backup_path"
}

# Function to update config.json for format_version 1b to 1c
update_1b_to_1c() {
    local generateGitTreeForReadme="\"generateGitTreeForReadme\": true"
    jq ". + {${generateGitTreeForReadme}, \"format_version\": \"1c\"}" "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
    echo "Updated dotctl to format_version 1c."
}

# Function to handle updates based on format_version
update_config() {
    local format_version="$1"

    case "$format_version" in
        1b)
            update_1b_to_1c
            ;;
        *)
            echo "No updates defined for format_version $format_version"
            return 1
            ;;
    esac

    return 0
}

# Check if config.json exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: $CONFIG_PATH does not exist."
    exit 1
fi

# Backup the existing config.json file
backup_file "$CONFIG_PATH" "$BACKUP_PATH"

# Loop to update config until no updates are required
while true; do
    format_version=$(jq -r '.format_version' "$CONFIG_PATH")
    if ! update_config "$format_version"; then
        break
    fi
done

echo "Finished migrations."
