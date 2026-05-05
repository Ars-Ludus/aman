# aman - Alias Manager for Linux

`aman` is a CLI utility designed to manage shell aliases and PATH-based wrapper scripts with built-in conflict detection and backup capabilities.

## Features

- **Shell Aliases:** Manage Bash/Zsh aliases that support pipes, variables, and redirections.
- **PATH Aliases:** Create executable wrapper scripts in `~/.aman/bin` that work across all programs.
- **Conflict Detection:** Prevents overwriting existing system commands or existing aliases.
- **Backups:** Automatically backs up your alias configuration before modifications.
- **Import/Export:** Easily migrate your aliases between machines using JSON files.
- **Interactive Menu:** User-friendly interactive interface for managing aliases.

## Installation

### Quick install (recommended)

```bash
bash <(curl -sL https://raw.githubusercontent.com/Ars-Ludus/aman/main/install.sh)
```

### From source

```bash
git clone https://github.com/Ars-Ludus/aman.git
cd aman
bash install.sh
```

Custom path:

```bash
bash install.sh ~/.local/bin
```

### Uninstall

```bash
bash install.sh --uninstall
```

### What gets installed

The `bin/aman` script is placed on your PATH. Data lives in `~/.aman/`:
- `config.json`: Metadata and alias definitions.
- `aliases.sh`: The generated script sourced by your shell.
- `bin/`: Executable wrappers.

## Usage

```bash
aman <command> [options]
```

### Commands:
- `ls`, `list`: List all managed aliases.
- `add`, `create`, `mk`: Create a new alias (interactive).
- `edit`, `change`, `update`: Modify an existing alias.
- `rm`, `remove <name>`: Remove an alias.
- `export [path]`: Export aliases to a JSON file.
- `import <file>`: Import aliases from a JSON file.
- `menu`: Open the interactive menu interface.
- `help`: Show help information.

## Shell Integration

Add the following to your `~/.bashrc` or `~/.zshrc`:

```bash
# Add aman bin directory to PATH
export PATH="$HOME/.aman/bin:$PATH"

# Source aman aliases
source ~/.aman/aliases.sh
```
