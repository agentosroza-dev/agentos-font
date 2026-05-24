# agentos-font

Khmer fonts for AgentOS UI, with fontconfig priority configuration.

## Install

```sh
curl -sSL https://raw.githubusercontent.com/agentosroza-dev/agentos-font/main/install.sh | sh
```

This installs fonts to the system font directory and copies fontconfig files
(`~/.config/fontconfig/`) to set `AgentosUI` as the preferred font family.

## Uninstall

```sh
curl -sSL https://raw.githubusercontent.com/agentosroza-dev/agentos-font/main/install.sh | sh -s -- uninstall
```

Removes both fonts and fontconfig files.

### Custom font directory

```sh
curl -sSL https://raw.githubusercontent.com/agentosroza-dev/agentos-font/main/install.sh | FONT_DIR=/custom/path sh
```
