# DosBox-X Chonker Game

This a game written in X86 assembly language which emulates a chonker digging a tunnel. The goal is for the chonker (#) to dig a tunnel (X) while avoiding the rocks (R). This game is meant to be playable in DosBox-X. The source code can be seen in `sample.asm`.

<img src="./imgs/Screenshot from 2022-11-12 13-38-58.png">

# Installing DosBox
Before running the game DosBox needs to be install (download <a src="https://www.dosbox.com/download.php?main=1">here</a>).

# DosBox Setup
Now that DosBox is setup mount this directory using the command ```mount C {'path'}``` where ```path``` is the path to this directory. Now access this mounted drive using ```C:```.

## Compiling Assembly:
We can recompile `SAMPLE.exe` using the command `ml sample.asm`.

## Running Game:
We can run the game using the command `SAMPLE.exe`.

# Controls
- To move left use the `a` key
- To move right use the `s` key