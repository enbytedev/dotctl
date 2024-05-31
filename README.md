<p align="center">
  <a href="https://github.com/enbytedev/dotctl"><img src="https://raw.githubusercontent.com/enbytedev/dotctl/main/ICON.png" width="250" height="250" /></a>
  <h3 align="center">✨ dotctl ✨</h3>
  <p align="center"><i>easily manage your dotfiles!</i></p>
</p>

## Installation

To install system-wide, you can use the provided script or PKGBUILD file. If you plan to install from the install.sh script, please ensure you have all required packages installed.
*(Remember, NEVER run scripts if you haven't checked what they do!)*

**install.sh**
```shell
chmod +x ./install.sh
./install.sh
```

**PKGBUILD**
```shell
makepkg -si
```

Either method will install the collection of scripts required to run dotctl. These scripts are located in /usr/local/share/dotctl by default.

## Commands and Flags

| Command              | Flags                            | Description                                                                                   |
|----------------------|----------------------------------|-----------------------------------------------------------------------------------------------|
| `--help`             | `-h`                             | Display the help menu                                                                         |
| `--sync`             | `-s`                             | Sync dotfiles from remote (if applicable) to base, and processed to intermediate                                                                      |
| `--gen-changes`      | `-g`                             | Generate changes that can be imported/exported seperate from the base dotfiles                                                               |
| `--config`           | `-c`                             | Open config.json in the system editor (falls back to nano)                                |
| `--dir`              | `-d ` | Open ~/.dotctl directory in the file manager                                                  |
|                      | `-d i`, `-d intermediate`              | Open the intermediate directory                                                               |
|                      | `-d b`, `-d base`                      | Open the base directory                                                                       |
|                      | `-d c`, `-d changes`                   | Open the changes directory                                                                    |
| `--export`           | `-e [arg]`                       | Export changes as tarball with an optional argument for file name (defaults to 'export')                |
| `--import`           | `-i [path]`                      | Import changes as tarball from the specified path                                                       |
| `--flush`            |                                  | Flush changes; delete and recreate changes directory                                       |
| `--merge`            |                                  | Merge your intermediate into base overwrite base with intermediate                                            |
| `--git-init`         |                                  | Initialize or clone a repository in the base directory                   |

## Configuration

You can specify what to load and where using JSON. An example config file is shown below:


```json
{
    "format_version": "1b",
    "structure": {
        "home": "/home/tommy/",
        "dot-config": "/home/tommy/.config/",
        "etc": "/etc/"
    }
}
```

In this instance, the base folder may look like this:

```
base
├── dot-config
│   ├── hypr
│   │   ├── hyprland.conf
│   │   ├── hyprpaper.conf
│   │   └── wallpaper.png
│   ├── kitty
│   │   └── kitty.conf
│   └── mako
├── etc
│   └── sddm.conf
├── home
│   ├── dot-bashrc
│   └── Scripts
│       ├── appmenu.sh
│       ├── watch.sh
│       └── wsmenu.sh
```

Additionally, a value called format_version is stored so that any future updates carry minimal risk of data loss.