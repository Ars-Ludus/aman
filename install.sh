#!/bin/bash
#
# install.sh - Install aman (alias manager) to your system
#
# Usage:
#   bash install.sh            # Install to detected location
#   bash install.sh /custom/path  # Install to custom path
#   bash install.sh --uninstall # Remove aman from system
#   bash install.sh --help      # Show help
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AMAN_SOURCE="$SCRIPT_DIR/bin/aman"
AMAN_VERSION=$(grep "^AMAN_VERSION" "$AMAN_SOURCE" | head -1 | sed 's/.*"\(.*\)"/\1/' 2>/dev/null || echo "unknown")
INSTALL_TARGET="${1:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Help ---
show_help() {
    cat <<EOF
aman ${AMAN_VERSION} - Installer

USAGE:
    bash install.sh [target|--uninstall|--help]

DEFAULTS:
    Detects best location automatically:
      1. ~/.local/bin      (user install, preferred)
      2. /usr/local/bin     (system install, requires sudo)
      3. ~/bin              (fallback)

OPTIONS:
    /custom/path    Install to a specific directory
    --uninstall     Remove aman from the system
    --help          Show this help message

EOF
    exit 0
}

# --- Detect target directory ---
detect_install_target() {
    # Check each candidate in order of preference
    for candidate in "$HOME/.local/bin" "/usr/local/bin" "$HOME/bin"; do
        if [ -d "$candidate" ] && echo "$PATH" | tr ':' '\n' | grep -qx "$candidate" 2>/dev/null; then
            echo "$candidate"
            return
        fi
    done

    # Preferred but might need to be created
    if [ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin" 2>/dev/null; then
        echo "$HOME/.local/bin"
        return
    fi

    # Fallback: create ~/bin
    mkdir -p "$HOME/bin" 2>/dev/null
    echo "$HOME/bin"
}

# --- Check if target is in PATH ---
ensure_in_path() {
    local target_dir="$1"
    if ! echo "$PATH" | tr ':' '\n' | grep -qx "$target_dir" 2>/dev/null; then
        local shell_rc="$HOME/.bashrc"
        [ -f "$HOME/.zshrc" ] && shell_rc="$HOME/.zshrc"

        echo ""
        echo -e "${YELLOW}⚠️  $target_dir is not in your PATH${NC}"
        echo -e "${YELLOW}   Add this to $shell_rc:${NC}"
        echo ""
        echo "   export PATH=\"$target_dir:\$PATH\""
        echo ""
    fi
}

# --- Install ---
do_install() {
    local target_dir="$1"
    local install_path="$target_dir/aman"

    mkdir -p "$target_dir"

    if [ ! -f "$AMAN_SOURCE" ]; then
        echo -e "${RED}❌ Source not found: $AMAN_SOURCE${NC}"
        exit 1
    fi

    # Check if we have write permission
    if [ -f "$install_path" ] && [ ! -w "$install_path" ]; then
        echo -e "${YELLOW}⚠️  Need sudo to update existing install at $install_path${NC}"
        sudo cp "$AMAN_SOURCE" "$install_path"
        sudo chmod +x "$install_path"
    elif [ ! -w "$target_dir" ]; then
        echo -e "${YELLOW}⚠️  Need sudo to write to $target_dir${NC}"
        sudo cp "$AMAN_SOURCE" "$install_path"
        sudo chmod +x "$install_path"
    else
        cp "$AMAN_SOURCE" "$install_path"
        chmod +x "$install_path"
    fi

    echo -e "${GREEN}✅ aman ${AMAN_VERSION} installed to ${install_path}${NC}"
    ensure_in_path "$target_dir"
}

# --- Uninstall ---
do_uninstall() {
    local found=false

    for dir in "$HOME/.local/bin" "/usr/local/bin" "$HOME/bin"; do
        local candidate="$dir/aman"
        if [ -f "$candidate" ]; then
            echo -e "${YELLOW}Found at: $candidate${NC}"
            if [ ! -w "$candidate" ]; then
                echo -e "${YELLOW}   Removing with sudo...${NC}"
                sudo rm -f "$candidate"
            else
                rm -f "$candidate"
            fi
            echo -e "${GREEN}   ✓ Removed${NC}"
            found=true
        fi
    done

    if [ "$found" = false ]; then
        echo -e "${YELLOW}⚠️  aman is not installed on this system.${NC}"
    else
        echo ""
        echo -e "${GREEN}✅ aman has been uninstalled.${NC}"
        echo -e "${YELLOW}Note: Your alias data at ~/.aman/ has not been removed.${NC}"
    fi
}

# --- Main ---
main() {
    case "${INSTALL_TARGET}" in
        --help|-h)
            show_help
            ;;
        --uninstall)
            do_uninstall
            ;;
        "")
            local target=$(detect_install_target)
            do_install "$target"
            ;;
        *)
            do_install "$INSTALL_TARGET"
            ;;
    esac
}

main
