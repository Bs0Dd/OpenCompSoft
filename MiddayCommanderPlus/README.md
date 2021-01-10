# Midday Commander Plus
*A file manager utility for OpenComputers. Forked from [original MC](https://github.com/OpenPrograms/OpenPrograms.ru/tree/master/mc)*.

Made for those who are not experienced with command-line interfaces.

## Developers
* Zer0Galaxy (aka Dimus) — the ComputerCraft version of the original program.
* NEO (a.k.a. Avaja) — the file search algorithm.
* Totoro (also known as MoonlightOwl) — the OpenComputers port.
* Bs()Dd (also spelled Bs0Dd) - the Plus version.

## Installation
Insert Internet card and type: `pastebin run `

## Description
The programs supports any screens with any color depth or resolution.

<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Video1.png" alt="Screenshot 1" width="230" height="153"> <img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Video2.png" alt="Screenshot 2" width="230" height="148"> <img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Video3.png" alt="Screenshot 3" width="230" height="146">

The GUI was inspired by a well-known Linux program, Midnight Commander, and, of course, Norton Commander.

The program GUI has two panels, to the left and to the right.
Each one lists files and directories stored on the computer's HDDs or floppies.
The directories have `/` at the end of their names, and are displayed on the top
of the lists.

Below it is a command prompt, and a list of the actions invoked by pressing
a corresponding functional (`Fn`) key.

Use arrow keys to navigate through the files, and pressing the `Tab` key moves
the focus to another panel. The `Enter` key is used to run a program or go to
a directory. To run a program and pass it arguments, hold `Ctrl` and press
`Enter`. The name of program will be pasted to the command prompt.
Type the arguments, and press `Enter`.

Also, you can press `Alt` + `Enter` to hide MC.

## Actions

`F1` — show help.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Help.png" alt="Screenshot 4: The help window" width="230" height="146">

`F4` — open an editor with the selected file.

`Shift` + `F4` — create a new file.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Newfile.png" alt="Screenshot 5: The "Create new file" dialog" width="230" height="146">

`F5`/`F6` — copy/move a selected file to the another panel's current directory. You can
copy under another name if you want so.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Copy.png" alt="Screenshot 6: The "Copy the file" dialog" width="230" height="146">

`F7` — create a new directory.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Newdir.png" alt="Screenshot 7: The "Copy the file" dialog" width="230" height="146">

`Alt` + `F7` — search for a file or directory.  
You can use `?` and `*` masks.

* `?` means "any character".
* `*` means "0 or more characters"

For example, to search for all files that start with `co`, you can use the `co*`
pattern.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Video3.png" alt="Screenshot 78" width="230" height="146"> <img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Video3.png" alt="Screenshot 3" width="230" height="146">
![Screenshot 6: The "Search" dialog](http://computercraft.ru/uploads/monthly_04_2016/post-7-0-58966600-1459869362.png)
![Screenshot 7: The "Search results" dialog](http://computercraft.ru/uploads/monthly_04_2016/post-7-0-58966600-1459869362.png)

`F8` — remove a file or directory. You'll be asked for confirmation before
removing.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Video3.png" alt="Screenshot 9" width="230" height="146">
![Screenshot 9: The "Remove the file" dialog](http://computercraft.ru/uploads/monthly_04_2016/post-7-0-34415400-1459869339.png)

`F10` — exit.  


## Links
* [The topic on the forum](http://computercraft.ru/topic/)
* [Installer on Pastebin](http://pastebin.com/)
