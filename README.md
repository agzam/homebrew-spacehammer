# Homebrew Tap for Spacehammer

[Spacehammer](https://github.com/agzam/spacehammer) - Spacemacs/Doom-inspired modal toolkit for Hammerspoon.

## Installation

```bash
brew tap agzam/spacehammer
brew install --cask spacehammer
```

With custom config repo:
```bash
CONFIG_REPO=git@github.com:username/my-config.git brew install --cask spacehammer
```

## Prerequisites

Before installing, backup and remove existing directories:
```bash
mv ~/.hammerspoon ~/.hammerspoon.backup
mv ~/.spacehammer ~/.spacehammer.backup
```

## Uninstalling

```bash
brew uninstall --cask spacehammer
rm -rf ~/.hammerspoon ~/.spacehammer
```

## More Info

https://github.com/agzam/spacehammer
