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
  nvm
  python
  yarn
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

# vscode=(
#   # Add VS Code extension IDs here, then uncomment this array
#   # and the install line in the "Install secondary packages" section below.
# )

fonts=(
  font-fira-code
  font-jetbrains-mono
  font-source-code-pro
)

# Packages that must be fully installed in CI (prerequisites for non-brew steps)
ci_real_install=(
  gh        # needed for: gh extension install
  node      # needed for: npm install --global
)

######################################## End of app list ########################################
set +e
set -x

# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

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

prompt "Set git defaults"
for config in "${git_configs[@]}"
do
  key="${config%% *}"
  value="${config#* }"
  git config --global "${key}" "${value}"
done

prompt "Install software"
install 'brew install --cask' "${casks[@]}"

prompt "Install gh extensions"
gh extension install github/gh-copilot

prompt "Install secondary packages"
install 'npm install --global' "${npms[@]}"
# Uncomment when vscode extensions are added to the vscode array above
#install 'code --install-extension' "${vscode[@]}"
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
