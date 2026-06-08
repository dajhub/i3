# i3

![i3-desktop](assets/i3.png)

### Introduction
A fedora minimal install via [Fedora Everything](https://fedoraproject.org/misc/#everything), i.e. no initial desktop.

### Installation
- After a minimal installation reboot into terminal and clone repository:
```bash
sudo dnf install git
git clone https://github.com/dajhub/i3
```

- Install i3 and folders (check `install-fedora.sh`):

```bash
./install-fedora.sh
```

> [!NOTE]
>
> `install-fedora.sh` runs `folders.sh` which runs rsync to copy folders across.
> If, subsequently, changes are made in those folder (e.g. changes to i3 config file) then running `~/i3/update-dots.sh`
> will update the i3 folder with the changes.

### Troubleshoot
##### Touchpad Not Working
If the touchpad is not working, then this may help solve (again, worth checking the script first):

```bash
cd i3/touchpad.sh
./touchpad.sh
``

Content of the script:

```bash
sudo tee -a /etc/X11/xorg.conf.d/30-touchpad.conf << 'EOF'
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
EndSection
EOF
```


