# solvers dotfiles

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
