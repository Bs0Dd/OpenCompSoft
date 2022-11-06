# Midday Commander Plus
*A file manager utility for OpenComputers. Forked from [original MC](https://github.com/OpenPrograms/OpenPrograms.ru/tree/master/mc)*.

Made for those who are not experienced with command-line interfaces.

## Developers
* Zer0Galaxy (aka Dimus) — the ComputerCraft version of the original program.
* NEO (a.k.a. Avaja) — the file search algorithm.
* Totoro (also known as MoonlightOwl) — the OpenComputers port.
* Bs()Dd (also spelled Bs0Dd) - the Plus version.

## Installation
Insert Internet card and type: `pastebin run pc73b8bB`

The program comes with:
   1. Language mcl files for Russian and English (by default, English is set)
   2. Three mct themes - "Standard", "Redstone" and "Darkness" (alas, I am not a designer, so the absence of eyelash in themes is not guaranteed)

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

Use arrow keys or mouse to navigate through the files, and pressing the `Tab` key or clicking on another panel moves
the focus to another panel. The `Enter` key (or double click) is used to run a program or go to
a directory. To run a program and pass it arguments, hold `Ctrl` and press
`Enter` (or double click on the element). The name of program will be pasted to the command prompt.
Type the arguments, and press `Enter`.

Also, you can press `Alt` + `Enter` to hide MCP.

The main differences from the original version:
  1. Supports 160x50 video mode
  2. Shadows by the windows (like Norton)
  3. Mouse support
  4. Multilingual (language data is placed in a separate .mcl file)
  5. Themes support (data on colors of elements are placed in a separate .mct file)
  6. Association system

Program parameters are located in the config file - `/etc/mc.cfg`

## Associaton system

In modern operating systems like Linux, MacOS and Windows, when opening, say, a .jpg image, the system will not launch it, but will launch the viewer associated with this format, passing it this file. A similar system is implemented here.
In the config there is a field "Associations", where you can specify for which file which program will be launched.

Entries are of the form ['extension'] = 'program and arguments'.

For example, the entry ['.txt'] = 'edit' means that when you double-click on a file with the .txt extension, the edit editor will be called with the path argument to the file.

Associations do not work if the file is launched from the manager command line.

## Actions

`F1` — show help.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Help.png" alt="Screenshot 4: The help window" width="230" height="146">

`F3` — open an editor with the selected file.

`Shift` + `F3` — create a new file.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Newfile.png" alt="Screenshot 5: The &#34;Create new file&#34; dialog" width="230" height="146">

`F4`/`F5` — copy/move a selected file to the another panel's current directory. You can
copy under another name if you want so.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Copy.png" alt="Screenshot 6: The &#34;Copy the file&#34; dialog" width="230" height="146">

`F7` — create a new directory.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Newdir.png" alt="Screenshot 7: The &#34;Directory name&#34; dialog" width="230" height="146">

`Alt` + `F7` — search for a file or directory.  
You can use `?` and `*` masks.

* `?` means "any character".
* `*` means "0 or more characters"

For example, to search for all files that start with `co`, you can use the `co*`
pattern.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Find.png" alt="Screenshot 8: The &#34;Search&#34; dialog" width="230" height="146"> <img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Results.png" alt="Screenshot 8: The &#34;Search results&#34; dialog" width="230" height="146">

`F8` — remove a file or directory. You'll be asked for confirmation before
removing.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Delete.png" alt="Screenshot 9: The &#34;Remove the file&#34; dialog" width="230" height="146">

`F10` — exit.  
<img src="https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Screenshots/Eng/Exit.png" alt="Screenshot 9: The &#34;Exit&#34; dialog" width="230" height="146">

## Links
* [The topic on the forum](https://computercraft.ru/topic/3952-midday-commander-plus-vozrozhdenie-iz-pepla/)
* [Installer on Pastebin](https://pastebin.com/pc73b8bB)
