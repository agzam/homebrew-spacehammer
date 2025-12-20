# Homebrew Tap for Spacehammer

This tap provides a Homebrew formula for [Spacehammer](https://github.com/agzam/spacehammer), a Spacemacs/Doom-inspired modal toolkit for Hammerspoon.

## Installation

```bash
brew tap agzam/spacehammer
brew install spacehammer
```

This will automatically install:
- Hammerspoon (if not already installed)
- Fennel (required dependency)
- Spacehammer configuration files to `~/.hammerspoon`

### Install Options

**Install from master branch (latest):**
```bash
brew install spacehammer --HEAD
```

**Install with custom config repository:**
```bash
SPACEHAMMER_CONFIG_REPO=git@github.com:username/my-spacehammer-config.git \
brew install spacehammer
```

## What Gets Installed

- `~/.hammerspoon` - Spacehammer core files
- `~/.spacehammer` - Your custom configuration (created on first launch, or cloned if `SPACEHAMMER_CONFIG_REPO` is set)

## Usage

After installation:
1. Launch Hammerspoon (if not already running)
2. Press `Option+Space` (default LEAD key) to open the modal menu

## Uninstalling

```bash
brew uninstall spacehammer
```

**Note:** Your `~/.hammerspoon` and `~/.spacehammer` directories are NOT automatically removed during uninstall. Remove them manually if desired:

```bash
rm -rf ~/.hammerspoon ~/.spacehammer
```

## Notes

- If you have an existing `~/.hammerspoon` directory, it will be backed up with a timestamp before installation
- If `~/.hammerspoon` is a git repository, you'll get a 5-second warning to cancel and commit/push changes first
- Your custom configuration in `~/.spacehammer` is preserved during upgrades
- To install with your own config repository, set the `SPACEHAMMER_CONFIG_REPO` environment variable during installation

## More Information

Visit the [Spacehammer repository](https://github.com/agzam/spacehammer) for documentation and configuration examples.
