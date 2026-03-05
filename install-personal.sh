#!/usr/bin/env bash

# Personal-only software — apps that don't belong on a work machine.

personal_casks=(
  affinity
  affinity-designer
  affinity-publisher
  calibre
  discord
  signal
  steam
)

personal_brews=(
  imagemagick
)

######################################## End of app list ########################################
set +e
set -x

# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

if test ! "$(command -v brew)"; then
  echo "Homebrew is not installed. Please run install.sh first or install Homebrew manually."
  exit 1
fi
export HOMEBREW_NO_AUTO_UPDATE=1

prompt "Install personal packages"
install 'brew_install_or_upgrade' "${personal_brews[@]}"

prompt "Install personal software"
install 'brew install --cask' "${personal_casks[@]}"

prompt "Cleanup"
brew cleanup

echo "Done!"
