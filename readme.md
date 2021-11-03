Tetris in daScript
* Information about controls is available in game on start screen
* Adds bonuses concept: for destroying many lines, epecially several with one figure, one of three options can be used, when it will be needed:
1) Remove bottom line
2) Destroy current figure
3) Slowdown time
* Uses ECS for flying balls in background (not used for main game, because all processing actually happens on only one falling figure)
* Launch: dasbox.exe main.das
* dasbox.exe is taken from releases at https://github.com/imp5imp5/dasbox
