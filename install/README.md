# Installer scripts

These are the two scripts that the one-line install commands run:

| Script | Run it with | For |
| --- | --- | --- |
| [install.sh](install.sh) | `curl -fsSL https://cli.thedreamlabinnovations.com/install.sh \| sh` | macOS, Linux and Windows Subsystem for Linux |
| [install.ps1](install.ps1) | `irm https://cli.thedreamlabinnovations.com/install.ps1 \| iex` | Windows (PowerShell, not as administrator) |

They are copied here with every release, so you can read what they do before you run them. Each one downloads the
build for your computer from `cli.thedreamlabinnovations.com`, checks its SHA-256 checksum against the list
published with the release, checks that it starts, and installs it for your user account only, with no
administrator rights.

- On macOS and Linux, rbai goes to `~/.rbai/bin/rbai`, and one line ending in `# rbai` is added to your shell's
  startup file so that the command is found.
- On Windows, rbai goes to `%LOCALAPPDATA%\Programs\rbai\rbai.exe`, and that folder is added to your user Path.

Open a new terminal afterwards. Running the same command again updates rbai, and so does `rbai update`.

Without curl, for example on Alpine Linux:

```sh
wget -qO- https://cli.thedreamlabinnovations.com/install.sh | sh
```

## Options

| To | Do this |
| --- | --- |
| Install a given version | `curl -fsSL https://cli.thedreamlabinnovations.com/install.sh \| RBAI_VERSION=1.7.0 sh`, or in PowerShell `$env:RBAI_VERSION = '1.7.0'; irm https://cli.thedreamlabinnovations.com/install.ps1 \| iex` |
| Install into another folder | Set `RBAI_INSTALL_DIR` first, for example `RBAI_INSTALL_DIR="$HOME/tools/rbai"`, or in PowerShell `$env:RBAI_INSTALL_DIR = 'D:\Tools\rbai'` |
| Leave your PATH alone | Set `RBAI_NO_MODIFY_PATH=1` first |

## Uninstall

Run `rbai auth logout` first, so the key that your sign-in created is revoked. Then:

- on macOS and Linux, delete `~/.rbai/bin` and the line ending in `# rbai` in your shell's startup file;
- on Windows, delete `%LOCALAPPDATA%\Programs\rbai` and remove it from your user Path.

With npm, run `npm uninstall -g rbai-cli` instead.
