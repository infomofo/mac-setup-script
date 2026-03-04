[![CI](https://github.com/infomofo/mac-setup-script/actions/workflows/build.yaml/badge.svg)](https://github.com/infomofo/mac-setup-script/actions/workflows/build.yaml)

Dead simple script to setup my new Mac:

```shell
cd ~/Downloads
curl -sL https://raw.githubusercontent.com/infomofo/mac-setup-script/main/defaults.sh | bash
curl -O https://raw.githubusercontent.com/infomofo/mac-setup-script/main/install.sh
chmod +x install.sh
./install.sh
```

On a personal machine, also run:

```shell
curl -O https://raw.githubusercontent.com/infomofo/mac-setup-script/main/install-personal.sh
chmod +x install-personal.sh
./install-personal.sh
```
