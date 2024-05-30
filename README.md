<p align="center">
  <h3 align="center">✨ dotfiles ✨</h3>
  <p align="center"><i>easily manage your dotfiles!</i></p>
</p>

<hr>
This tool requires stow and jq. On Arch, they can be installed with Pacman:

```shell
sudo pacman -S stow jq
```

To install system-wide, you can use the provided script to generate a wrapper.
*(Remember, NEVER run scripts if you haven't checked what they do!)*

```shell
chmod +x make-dotctl.sh
./make-dotctl.sh
```

With dotctl installed and configured, its time to sync your dotfiles!:

```shell
dotctl --sync
```

These files will be placed in your "intermediate" folder with any applicable patches applied. This folder can be accessed by running with the --intermediate-dir or -id flag:

```shell
dotctl --intermediate-dir
```

Likewise, the base directory can be accessed by the --base-dir or -bd flag:

```shell
dotctl --base-dir
```

Any changes made in the intermediate directory will be overwritten by the sync command. This is to avoid keeping any modifications that are undesirable. To save modifications separately (or privately if tokens are involved,) utilize patches. Running with the --gen-patches or -p flag will generate patches based on the differences between the base folder and the intermediate folder.

```shell
dotctl --gen-patches
```

To access the patch folder, run with --patches-dir or -pd.

```shell
dotctl --patches-dir
```

Here you will find all of the changes made to the intermediary folder as patch files. These can be backed up seperately.

All modification to these dotfiles should be done through the generated system folders. Do not delete these folders.

You can specify what to load and where using JSON. An example is shown below:

```json
{
    "home": "/home/tommy/",
    "dot-config": "/home/tommy/.config/",
    "etc": "/etc/"
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