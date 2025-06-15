#!/bin/bash

# Function to detect appropriate pip config file location
get_pip_config_path() {
    # Common locations for pip.conf
    local possible_locations=(
        "$HOME/.config/pip/pip.conf"  # Modern Linux standard
        "$HOME/.pip/pip.conf"        # Alternative location
        "/etc/pip.conf"              # System-wide (if root)
    )

    # Check for XDG_CONFIG_HOME
    if [ -n "$XDG_CONFIG_HOME" ]; then
        possible_locations[0]="$XDG_CONFIG_HOME/pip/pip.conf"
    fi

    # Return first writable location
    for location in "${possible_locations[@]}"; do
        local dir
        dir=$(dirname "$location")
        if [ -w "$dir" ] || mkdir -p "$dir" 2>/dev/null; then
            echo "$location"
            return 0
        fi
    done

    echo "ERROR: No writable pip configuration directory found" >&2
    return 1
}

# Main script
main() {
    # Get pip config path
    PIP_CONFIG_FILE=$(get_pip_config_path) || exit 1

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$PIP_CONFIG_FILE")" || {
        echo "ERROR: Failed to create directory for pip configuration" >&2
        exit 1
    }

    # Backup existing config if it exists
    if [ -f "$PIP_CONFIG_FILE" ]; then
        cp "$PIP_CONFIG_FILE" "${PIP_CONFIG_FILE}.backup" || {
            echo "ERROR: Failed to backup existing pip configuration" >&2
            exit 1
        }
        echo "Backed up existing configuration to ${PIP_CONFIG_FILE}.backup"
    fi

    # Write new configuration
    {
        echo "[global]"
        echo "break-system-packages = true"
    } > "$PIP_CONFIG_FILE" || {
        echo "ERROR: Failed to write pip configuration" >&2
        exit 1
    }

    # Verify and display results
    echo "Pip configuration updated successfully"
    echo "Configuration file location: $PIP_CONFIG_FILE"
    echo "Contents:"
    cat "$PIP_CONFIG_FILE"
}

# Execute main function
main
