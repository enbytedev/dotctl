#!/bin/bash

# Check if the version is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION=$1

# Directory containing the scripts
SCRIPTS_DIR=/usr/local/share/dotctl

# Add version tag to all .sh files in the specified directory
for file in $SCRIPTS_DIR/*.sh; do
  if [[ -f $file ]]; then
    # Check if the file already has a version tag
    if ! grep -q "dotctl version" "$file"; then
      # Add the version tag after the shebang line
      sudo sed -i "2i # dotctl version $VERSION" "$file"
    else
      # Update the existing version tag
      sudo sed -i "s/^# dotctl version .*/# dotctl version $VERSION/" "$file"
    fi
  fi
done

echo "Added version tag to all scripts in $SCRIPTS_DIR"
