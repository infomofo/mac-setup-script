#!/usr/bin/env bash

# Install some stuff before others!
important_casks=(
  google-chrome
  iterm2
  slack
  visual-studio-code
)

brews=(
  ##### Install these first ######
  awscli
  bash
  gh
  git
  python3
  ################################
  atlassian-labs/acli/acli
  coreutils
  fzf
  #hosts
  gemini-cli
  jq
  macvim        # https://macvim-dev.github.io/macvim/
  node
  python
  reattach-to-user-namespace
  shellcheck
  tmux
  tree
  # "vim --with-override-system-vi"
  wget
  yamllint
  yq
)

casks=(
  github
  itsycal
  obsidian
  rectangle
  sourcetree
  warp
  zoom
)

npms=(
  @anthropic-ai/claude-code
  n           # https://github.com/tj/n
)

git_email='will.chiong@gmail.com'
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

vscode=(
)

fonts=(
  font-fira-code
  font-jetbrains-mono
  font-source-code-pro
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

if [[ -z "${CI}" ]]; then
  sudo -v # Ask for the administrator password upfront
  # Keep-alive: update existing `sudo` time stamp until script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

if test ! "$(command -v brew)"; then
  prompt "Install Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  if [[ -z "${CI}" ]]; then
    prompt "Update Homebrew"
    brew update
    brew upgrade
    brew doctor
  fi
fi
export HOMEBREW_NO_AUTO_UPDATE=1

echo "Install important software ..."
install 'brew install --cask' "${important_casks[@]}"

prompt "Install packages"
brew tap atlassian-labs/acli
install 'brew_install_or_upgrade' "${brews[@]}"
brew link --overwrite ruby

prompt "Set git defaults"
for config in "${git_configs[@]}"
do
  key="${config%% *}"
  value="${config#* }"
  git config --global "${key}" "${value}"
done

if [[ -z "${CI}" ]]; then
  # gpg --keyserver hkp://pgp.mit.edu --recv ${gpg_key}
  prompt "Export key to Github"
  ssh-keygen -t rsa -b 4096 -C "${git_email}"
  pbcopy < ~/.ssh/id_rsa.pub
  open https://github.com/settings/ssh/new
fi  

prompt "Upgrade bash"
sudo bash -c "echo $(brew --prefix)/bin/bash >> /private/etc/shells"
sudo chsh -s "$(brew --prefix)"/bin/bash

prompt "Install software"
install 'brew install --cask' "${casks[@]}"

prompt "Install gh extensions"
gh extension install github/gh-copilot

prompt "Install secondary packages"
install 'npm install --global' "${npms[@]}"
install 'code --install-extension' "${vscode[@]}"
install 'brew install --cask' "${fonts[@]}"

prompt "Update packages"
if [[ -z "${CI}" ]]; then
  m update install all
fi

if [[ -z "${CI}" ]]; then
  prompt "Install software from App Store"
  mas list
fi

prompt "Cleanup"
brew cleanup

echo "Done!"
