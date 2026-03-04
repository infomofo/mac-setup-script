#!/usr/bin/env bash

# Personal-only software — apps that don't belong on a work machine.

personal_casks=(
  affinity-designer-2
  affinity-photo-2
  affinity-publisher-2
  calibre
  discord
  signal
  steam
)

personal_brews=(
  imagemagick
  youtube-dl
)

######################################## End of app list ########################################
set +e
set -x

function prompt {
  if [[ -z "${CI}" ]]; then
    read -r -p "Hit Enter to $1 ..."
  fi
}

function install {
  cmd=$1
  shift
  for pkg in "$@";
  do
    exec="$cmd $pkg"
    #prompt "Execute: $exec"
    if ${exec} ; then
      echo "Installed $pkg"
    else
      echo "Failed to execute: $exec"
      if [[ -n "${CI}" ]]; then
        exit 1
      fi
    fi
  done
}

function brew_install_or_upgrade {
  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" > /dev/null); then
      echo "Upgrading already installed package $1 ..."
      brew upgrade "$1"
    else
      echo "Latest $1 is already installed"
    fi
  else
    brew install "$1"
  fi
}

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
