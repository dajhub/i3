# i3wm Configuration Shortcuts Reference

*Note: `$mod` is mapped to the **Super / Windows** key.*

---

##  Basic Keybindings

| Shortcut | Action | Command / Target |
| :--- | :--- | :--- |
| `$mod` + `Return` | Open Terminal | `kitty` |
| `$mod` + `b` | Open Web Browser | `vivaldi` |
| `$mod` + `v` | Open Text Editor | `vscodium` |
| `$mod` + `space` | Application Launcher | `rofi -show drun` |
| `$mod` + `w` | List Windows | `rofi -show window` |
| `$mod` + `Shift` + `e` | Show Menus / File Browser | `rofi -show filebrowser` |
| `$mod` + `Shift` + `r` | Reload i3 Configuration | `~/.config/i3/scripts/reload.sh` |

---

##  System Controls

| Shortcut | Action | Command / Target |
| :--- | :--- | :--- |
| `$mod` + `Control` + `Delete` | Power Off System | `systemctl poweroff` |
| `$mod` + `Control` + `r` | Reboot System | `systemctl reboot` |
| `$mod` + `Delete` | Exit i3wm | `i3-msg exit` |

---

##  Window Management

| Shortcut | Action | Command / Target |
| :--- | :--- | :--- |
| `$mod` + `q` | Kill Focused Window | `kill` |
| `$mod` + `c` | Toggle Floating Mode | `floating toggle` |
| `$mod` + `g` | Toggle Split / Group Layout | `layout toggle split` |
| `$mod` + `f` | Toggle Fullscreen Mode | `fullscreen toggle` |
| `$mod` + `Left` | Focus Left | Move focus |
| `$mod` + `Right` | Focus Right | Move focus |
| `$mod` + `Up` | Focus Up | Move focus |
| `$mod` + `Down` | Focus Down | Move focus |
| `$mod` + `Shift` + `h` | Move Window Left | Rearrange layout |
| `$mod` + `Shift` + `j` | Move Window Down | Rearrange layout |
| `$mod` + `Shift` + `k` | Move Window Up | Rearrange layout |
| `$mod` + `Shift` + `l` | Move Window Right | Rearrange layout |

###  Window Resizing
| Shortcut | Action | Modification |
| :--- | :--- | :--- |
| `$mod` + `Shift` + `Right` | Grow Window Width | `30px` |
| `$mod` + `Shift` + `Left` | Shrink Window Width | `30px` |
| `$mod` + `Shift` + `Up` | Shrink Window Height | `30px` |
| `$mod` + `Shift` + `Down` | Grow Window Height | `30px` |

###  Mouse Controls
| Shortcut | Action |
| :--- | :--- |
| `$mod` + `button1` (Left Click & Drag) | Move Window |
| `$mod` + `button3` (Right Click & Drag) | Resize Window |

---

##  Workspace Controls

| Shortcut | Action |
| :--- | :--- |
| `$mod` + `1` to `0` | Switch to Workspace `1` through `10` |
| `$mod` + `Shift` + `1` to `0` | Move Focused Container to Workspace `1` through `10` |
| `$mod` + `Tab` | Switch to Next Workspace |
| `$mod` + `grave` ( \` ) | Switch to Previous Workspace |

---

##  Layout Modes

| Shortcut | Action |
| :--- | :--- |
| `$mod` + `t` | Switch to Tabbed Layout |
| `$mod` + `s` | Switch to Stacking Layout |
| `$mod` + `e` | Toggle Split Layout |

---

##  Screenshots

| Shortcut | Action | Destination |
| :--- | :--- | :--- |
| `Print` | Fullscreen Screenshot | Clipboard Only |
| `Control` + `Print` | Fullscreen Screenshot | Saved to File |
| `$mod` + `Print` | Fullscreen Screenshot | Both File and Clipboard |
| `Shift` + `Print` | Area Selection Screenshot | Clipboard Only |
| `$mod` + `Shift` + `Print` | Area Selection Screenshot | Saved to File |

---

##  Hardware Controls

| Shortcut | Action | Command / Target |
| :--- | :--- | :--- |
| `XF86AudioMute` | Toggle Audio Mute | `pactl set-sink-volume @DEFAULT_SINK@ toggle` |
| `XF86AudioLowerVolume` | Decrease Volume (-5%) | `pactl set-sink-volume @DEFAULT_SINK@ -5%` |
| `XF86AudioRaiseVolume` | Increase Volume (+5%) | `pactl set-sink-volume @DEFAULT_SINK@ +5%` |
| `XF86AudioPlay` | Play / Pause Media | `playerctl play-pause` |
| `XF86AudioPause` | Play / Pause Media | `playerctl play-pause` |
| `XF86AudioNext` | Next Track | `playerctl next` |
| `XF86AudioPrev` | Previous Track | `playerctl previous` |
| `XF86MonBrightnessUp` | Increase Brightness (+10%) | `brightnessctl set +10%` |
| `XF86MonBrightnessDown` | Decrease Brightness (-10%) | `brightnessctl set 10%-` |
