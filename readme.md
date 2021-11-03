Tetris in daScript
* Information about controls is available in game on start screen
* Adds bonuses concept: for destroying many lines, epecially several with one figure, one of three options can be used, when it will be needed:
1) Remove bottom line
2) Destroy current figure
3) Slowdown time
* Uses ECS for flying balls in background (not used for main game, because all processing actually happens on only one falling figure)
* Launch: dasbox.exe main.das
* dasbox.exe is taken from releases at https://github.com/imp5imp5/dasbox
* Video sample: https://drive.google.com/file/d/1JmBX2PxPWENIgqjc99j7uYmhp1Ffs46w/view?usp=sharing Timecodes:
  1) Line removal bonus: 5:45
  2) Figure destroy bonus: 4:20
  3) Slowdown bonus: 5:20 - 5:35 (for quad figure down arrow was pressed several times, resulting in faster movement, so see next figure, until slowdown ends) 
