# solvers dotfiles

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo vim /etc/systemd/system/getty@tty1.service.d/override.conf

add:

[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin username --noclear %I $TERM

run:
sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.serivce


sudo pacman -S dash
sudo ln -sf /bin/dash /bin/sh

yay -S mksh
chsh -s /usr/bin/mksh

## disable bluetooth and wifi by default
sudo pacman -S bluez-utils
sudo systemctl disable bluetooth.service
sudo rfkill block bluetooth
sudo rfkill block wifi
sudo systemctl enable systemd-rfkill.service
sudo systemctl enable systemd-rfkill.socket

see ~/.mkshrc for activating bluetooth and wifi

run
sudo visudo
and add
yourusername ALL=(ALL) NOPASSWD: /usr/bin/systemctl start bluetooth.service, /usr/bin/systemctl stop bluetooth.service

sudo systemctl daemon-reexec
sudo systemctl restart NetworkManager

## vim

wget https://github.com/vim/vim/archive/refs/heads/master.tar.gz -O ~/dev/tools/repo-master.tar.gz
cd ~/dev/tools/
tar -xvf repo-master.tar.gz
cd vim-master

remove the arabic, sound and spell blocks from src/feature.h

make distclean

CFLAGS="-Os -fdata-sections -ffunction-sections" \
LDFLAGS="-Wl,--gc-sections -s" \
./configure \
  --prefix=$HOME/.local/vim-min \
  --with-features=normal \
  --without-x \
  --without-wayland \
  --disable-gui \
  --disable-selinux

make -j$(nproc)

make install

rm ~/.local/vim-min/bin/vimtutor

cd ~/.local/vim-min/share/vim/vim92/

rm -rf \
  tutor \
  colors \
  pack \
  tools \
  import \
  ftplugin \
  print \
  compiler \
  keymap \
  lang \
  macros \
  spell \
  plugin \
  autoload/cargo \
  autoload/rust \
  autoload/xml

cd syntax

rm -rf !(nosyntax.vim)

cd ..

rm -f \
  menu.vim \
  synmenu.vim \
  delmenu.vim \
  evim.vim \
  mswin.vim \
  bugreport.vim \
  vimrc_example.vim \
  gvimrc_example.vim \
  README.txt \
  LICENSE \
  optwin.vim \
  xdg.vim \
  autoload/*.vim

to get vim plugins to work run:<br>
~/cloneVimPlugins

to get inconsolate font, go the the next line and type Q<br>
sudo curl -o "/usr/share/fonts/TTF/inconsolata.bold.ttf" "https://st.1001fonts.net/download/font/inconsolata.bold.ttf"

## auto-cpufreq
git clone https://aur.archlinux.org/auto-cpufreq.git
cd auto-cpufreq
makepkg -si
sudo auto-cpufreq --install

## make root use lightweight vim
create the file /usr/local/bin/vim-sudo and add the text:
#!/bin/sh
exec /home/solver/.local/vim-min/bin/vim -u NONE "$@"

run the command:
sudo chmod +x /usr/local/bin/vim-sudo

run this command to open nano:
sudo EDITOR=nano visudo

and add this at the bottom:
Defaults    editor=/usr/local/bin/vim-sudo

## diff-so-fancy
put this in ~/.gitconfig:<br>
```
[core]
    pager = diff-so-fancy | less --tabs=4 -RFX
[interactive]
    diffFilter = diff-so-fancy --patch
[diff-so-fancy]
    markEmtpyLinse = true
    changeHunkIndicators = true
    stripLeadingSymbols = true
    useUnicodeRuler = false
    ruleerWidth = 0
[init]
    defaultBranch = main
[credential]
    helper = store
[color "status"]
    header = "#aaaaaa"
    added = "#00ff00"
    changed = "#ffff00"
    untracked = "#ff00ff"
    deleted = "#ff0000"
[color "diff"]
    context = "#aaaaaa"
    meta = "#00aaff"
    frag = "#00aaff"
    old = "#ff0000"
    new = "#00ff00"
```
