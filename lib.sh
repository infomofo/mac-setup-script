#!/usr/bin/env bash

# Shared shell functions sourced by install.sh and install-personal.sh.

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
    if [ -n "${CI}" ] && [[ "$cmd" == brew* ]] && [[ "$cmd" != brew_install_or_upgrade ]]; then
      exec="$cmd --dry-run $pkg"
    else
      exec="$cmd $pkg"
    fi
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
  # In CI, dry-run packages that aren't needed as prerequisites for later steps
  local -a dry_run=()
  if [ -n "${CI}" ]; then
    local is_ci_prerequisite=false
    # shellcheck disable=SC2154
    for ci_pkg in "${ci_real_install[@]}"; do
      if [[ "$1" == "$ci_pkg" ]]; then
        is_ci_prerequisite=true
        break
      fi
    done
    if [[ "$is_ci_prerequisite" == false ]]; then
      dry_run=(--dry-run)
    fi
  fi

  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" > /dev/null); then
      echo "Upgrading already installed package $1 ..."
      brew upgrade "${dry_run[@]}" "$1"
    else
      echo "Latest $1 is already installed"
    fi
  else
    brew install "${dry_run[@]}" "$1"
  fi
}
