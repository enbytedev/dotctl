#!/bin/bash

# Path to the scripts and config file
SCRIPT_PATH="/usr/local/share/dotctl"
SYNC_SCRIPT_PATH="$SCRIPT_PATH/sync.sh"
GEN_CHANGES_SCRIPT_PATH="$SCRIPT_PATH/gen-changes.sh"
EXPORT_CHANGES_SCRIPT_PATH="$SCRIPT_PATH/export.sh"
IMPORT_CHANGES_SCRIPT_PATH="$SCRIPT_PATH/import.sh"
FLUSH_CHANGES_SCRIPT_PATH="$SCRIPT_PATH/flush.sh"
MERGE_SCRIPT_PATH="$SCRIPT_PATH/merge.sh"
GIT_INIT_SCRIPT_PATH="$SCRIPT_PATH/git-init.sh"

CONFIG_PATH="$HOME/.dotctl/config.json"
DOTCTL_DIR="$HOME/.dotctl"
INTERMEDIATE_DIR="$DOTCTL_DIR/intermediate"
PATCHES_DIR="$DOTCTL_DIR/patches"
BASE_DIR="$DOTCTL_DIR/base"
CHANGES_DIR="$DOTCTL_DIR/changes"

# Source the color print functions
source $SCRIPT_PATH/print-functions.sh

# Function to display help menu
show_help() {
    print_blue "Usage: dotctl [OPTION]"
    print_gray "Options:"
    print_gray "  --help, -h                   Display this help menu"
    print_gray "  --sync, -s                   Sync dotfiles from remote (if applicable) to base, and processed to intermediate"
    print_gray "  --gen-changes, -g            Generate changes that can be imported/exported seperate from the base dotfiles"
    print_gray "  --config, -c                 Open config.json in the system editor (falls back to nano)"
    print_gray "  --dir, -d [i|intermediate|b|base|c|changes]  Open specified directory in the file manager"
    print_gray "  --export, -e [arg]           Export changes as tarball with an optional argument for file name (defaults to 'export')"
    print_gray "  --import, -i [path]          Import changes as tarball from the specified path"
    print_gray "  --flush                      Flush changes; delete and recreate changes directory"
    print_gray "  --merge                      Merge your intermediate into base overwrite base with intermediate"
    print_gray "  --git-init                   Initialize or clone a repository in the base directory"
}

# Function to open a file in the system's default editor, fallback to nano
open_in_editor() {
    if [ -n "$EDITOR" ]; then
        $EDITOR "$1"
    else
        nano "$1"
    fi
}

# Function to open the specified directory in the file manager
open_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        xdg-open "$dir" || open "$dir" & disown
    else
        print_gray "Error: Directory $dir does not exist."
        exit 1
    fi
}

# Parse command line arguments
case "$1" in
    --help|-h)
        show_help
        ;;
    --sync|-s)
        if [ -f "$SYNC_SCRIPT_PATH" ]; then
            "$SYNC_SCRIPT_PATH"
        else
            print_gray "Error: $SYNC_SCRIPT_PATH does not exist."
            exit 1
        fi
        ;;
    --gen-changes|-g)
        if [ -f "$GEN_CHANGES_SCRIPT_PATH" ]; then
            "$GEN_CHANGES_SCRIPT_PATH"
            print_gray "Please remember to back up your changes. To prevent data loss, a bundle of previous changes has been made. These will be deleted next time this script is run."
        else
            print_gray "Error: $GEN_CHANGES_SCRIPT_PATH does not exist."
            exit 1
        fi
        ;;
    --config|-c)
        if [ -f "$CONFIG_PATH" ]; then
            open_in_editor "$CONFIG_PATH"
        else
            print_gray "Error: $CONFIG_PATH does not exist."
            exit 1
        fi
        ;;
    --dir|-d)
        shift
        case "$1" in
            i|intermediate)
                open_directory "$INTERMEDIATE_DIR"
                ;;
            b|base)
                open_directory "$BASE_DIR"
                ;;
            c|changes)
                open_directory "$CHANGES_DIR"
                ;;
            *)
                open_directory "$DOTCTL_DIR"
                ;;
        esac
        ;;
    --export|-e)
        export_arg=${2:-export}
        if [ -f "$EXPORT_CHANGES_SCRIPT_PATH" ]; then
            "$EXPORT_CHANGES_SCRIPT_PATH" "$export_arg"
        else
            print_gray "Error: $EXPORT_CHANGES_SCRIPT_PATH does not exist."
            exit 1
        fi
        ;;
    --import|-i)
        import_path=${2:-~/.dotctl}
        if [ -f "$IMPORT_CHANGES_SCRIPT_PATH" ]; then
            "$IMPORT_CHANGES_SCRIPT_PATH" "$import_path"
        else
            print_gray "Error: $IMPORT_CHANGES_SCRIPT_PATH does not exist."
            exit 1
        fi
        ;;
    --flush)
        if [ -f "$FLUSH_CHANGES_SCRIPT_PATH" ]; then
            "$FLUSH_CHANGES_SCRIPT_PATH"
        else
            print_gray "Error: $FLUSH_CHANGES_SCRIPT_PATH does not exist."
            exit 1
        fi
        ;;
    --merge)
        if [ -f "$MERGE_SCRIPT_PATH" ]; then
            "$MERGE_SCRIPT_PATH"
        else
            print_gray "Error: $MERGE_SCRIPT_PATH does not exist."
            exit 1
        fi
        ;;
    --git-init)
        if [ -f "$GIT_INIT_SCRIPT_PATH" ]; then
            "$GIT_INIT_SCRIPT_PATH"
        else
            print_gray "Error: $GIT_INIT_SCRIPT_PATH does not exist."
            exit 1
        fi
        ;;
    *)
        print_gray "Invalid option: $1"
        show_help
        exit 1
        ;;
esac
