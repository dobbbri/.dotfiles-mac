#!/bin/bash

# Clean, uninstall, analyze, optimize, and monitor your Mac from the terminal.
# https://github.com/tw93/mole
# Optional args: -s latest for main branch code, -s 1.17.0 for specific version
curl -fsSL https://raw.githubusercontent.com/tw93/mole/main/install.sh | bash

# Run
#
# mo                           # Interactive menu
# mo clean                     # Deep cleanup + already-uninstalled app leftovers
# mo uninstall                 # Remove installed apps + their leftovers
# mo optimize                  # Refresh caches & services
# mo analyze                   # Visual disk explorer (or 'mo analyse')
# mo status                    # Live system health dashboard
# mo purge                     # Clean project build artifacts
# mo installer                 # Find and remove installer files
#
# mo touchid                   # Configure Touch ID for sudo
# mo completion                # Set up shell tab completion
# mo update                    # Update Mole
# mo update --nightly          # Update to latest unreleased main build, script install only
# mo remove                    # Remove Mole from system
# mo --help                    # Show help
# mo --version                 # Show installed version

# Preview safely
#
# mo clean --dry-run
# mo uninstall --dry-run
# mo history
# mo history --json
# mo purge --dry-run
#
# # Also works with: optimize, installer, remove, completion, touchid enable
# mo clean --dry-run --debug   # Preview + detailed logs
# mo optimize --whitelist      # Manage protected optimization rules
# mo clean --whitelist         # Manage protected caches
# mo purge --paths             # Configure project scan directories
# mo analyze /Volumes          # Analyze external drives only
