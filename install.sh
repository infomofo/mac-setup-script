#!/usr/bin/env bash

# Install some stuff before others!
important_casks=(
  firefox
  google-chrome
  iterm2
  slack
)

brews=(
  "imagemagick --with-webp"
  awscli
  bash
  bash-completion
  black
  ccrypt
  circleci
  coreutils
  git
  github/gh/gh
  gpg
  kubectx
  kubeseal
  kustomize
  node
  nvm
  postgresql
  pyenv
  python
  python3
  ruby
  skaffold
  tmux
  wget
  yarn
)

casks=(
  calibre
  discord
  docker
  flux
  itsycal
  jetbrains-toolbox
  resilio-sync
  slack
  sourcetree
  spectacle
  tunnelblick
  visual-studio-code
  vlc
  zoomus
)

git_email='will@infomofo.com'
git_configs=(
  "branch.autoSetupRebase always"
  "color.ui auto"
  "core.autocrlf input"
  "credential.helper osxkeychain"
  "merge.ff false"
  "pull.rebase true"
  "push.default simple"
  "rebase.autostash true"
  "rerere.autoUpdate true"
  "remote.origin.prune true"
  "rerere.enabled true"
  "user.name Will Chiong"
  "user.email ${git_email}"
)

fonts=(
    font-jetbrains-mono
)

######################################## End of app list ########################################
set +e
set -x

function prompt {
  if [[ -z "${CI}" ]]; then
    read -p "Hit Enter to $1 ..."
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
      if [[ ! -z "${CI}" ]]; then
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

if [[ -z "${CI}" ]]; then
  sudo -v # Ask for the administrator password upfront
  # Keep-alive: update existing `sudo` time stamp until script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

if test ! "$(command -v brew)"; then
  prompt "Install Homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  if [[ -z "${CI}" ]]; then
    prompt "Update Homebrew"
    brew update
    brew upgrade
    brew doctor
  fi
fi
export HOMEBREW_NO_AUTO_UPDATE=1

echo "Setting ZSH as shell..."
chsh -s /bin/bash

echo "Install important software ..."
brew tap caskroom/versions
install 'brew cask install' "${important_casks[@]}"

prompt "Install packages"
install 'brew_install_or_upgrade' "${brews[@]}"
brew link --overwrite ruby

prompt "Set git defaults"
for config in "${git_configs[@]}"
do
  git config --global ${config}
done

if [[ -z "${CI}" ]]; then
  prompt "Export key to Github"
  ssh-keygen -t rsa -b 4096 -C ${git_email}
  pbcopy < ~/.ssh/id_rsa.pub
  open https://github.com/settings/ssh/new
fi

echo "
alias ll='exa -l'
" >> ~/.bash_profile

prompt "Install software"
install 'brew cask install' "${casks[@]}"

prompt "Install secondary packages"
brew tap homebrew/cask-fonts
install 'brew cask install' "${fonts[@]}"

if [[ -z "${CI}" ]]; then
  prompt "Install software from App Store"
fi

prompt "Cleanup"
brew cleanup
brew cask cleanup

xcode-select --install

echo "Done!"
