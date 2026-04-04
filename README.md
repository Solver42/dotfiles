# solvers dotfiles

## vim

mkdir -p ~/dev/tools
wget https://github.com/vim/vim/archive/refs/heads/master.tar.gz -O ~/dev/tools/repo-master.tar.gz
cd ~/dev/tools/
tar -xvf repo-master.tar.gz
cd vim-master

remove the sound and spell blocks from src/feature.h

make distclean

CFLAGS="-Os -fdata-sections -ffunction-sections" \
LDFLAGS="-Wl,--gc-sections -s" \
./configure \
  --prefix=$HOME/.local/vim-min \
  --with-features=normal \
  --with-x \
  --enable-multibyte \
  --disable-gui \
  --disable-darwin \
  --disable-terminal \
  --disable-channel \
  --disable-netbeans \
  --disable-nls \
  --disable-luainterp \
  --disable-pythoninterp \
  --disable-python3interp \
  --disable-perlinterp \
  --disable-rubyinterp \
  --disable-tclinterp \
  --disable-mzschemeinterp \
  --disable-xsmp \
  --disable-xsmp-interact \
  --disable-gpm \
  --disable-selinux

make -j$(nproc)

make install

strip ~/.local/vim-min/bin/vim

cd ~/.local/vim-min/share/vim/vim92/
rm -rf
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
  syntax \
  autoload/cargo
  autoload/rust
  autoload/xml

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
