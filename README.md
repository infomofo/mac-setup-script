[![CI](https://github.com/infomofo/mac-setup-script/actions/workflows/build.yaml/badge.svg?branch=main)](https://github.com/infomofo/mac-setup-script/actions/workflows/build.yaml)

Dead simple script to setup my new Mac:

```shell
mkdir -p ~/Code
git clone https://github.com/infomofo/mac-setup-script.git ~/Code/mac-setup-script
cd ~/Code/mac-setup-script
bash defaults.sh
bash install.sh
```

Then set up dotfiles (shell config, vim, tmux, etc.) from the
[dotfiles repo](https://github.com/infomofo/dotfiles) — see its README for Keychain secrets
and service account key setup.

On a personal machine, also run:

```shell
bash install-personal.sh
```
