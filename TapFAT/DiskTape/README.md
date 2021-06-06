# DiskTape Lua BIOS

DiskTape - BIOS to boot the operating system from a cassette (with TapFAT filesystem) like a hard drive.  
It supports booting from OpenOS-like file (`init.lua`) and MineOS-like file (`OS.lua`).  
If the BIOS does not find a tape drive in the system, it will try to boot from standard devices.  
Please note that FS is very slow, therefore the system will run very slowly.

[![Video](https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/TapFAT/Pictures/driver.png)](https://www.youtube.com/watch?v=cBIY3tTLgQQ)

## How to setup

1. Download files `disktape.bin` and `bootldr.sys`
2. Flash `disktape.bin` to EEPROM
3. Prepare new tape by [this](https://github.com/Bs0Dd/OpenCompSoft/blob/master/TapFAT/README.md#prepare-tape) instructions
4. Install OS to tape
5. Copy Bootloader file (`bootldr.sys`) to the root of the cassette
6. Now you can insert EEPROM with the BIOS and boot from cassette

Ready-made cassete images (for six-minute cassette) with OpenOS and MineOS you can find in [this](https://github.com/Bs0Dd/OpenCompSoft/blob/master/TapFAT/DiskTape/Images) folder.
Use standard `tape` utility to write it. 

## What is bootldr.sys?

EEPROM size (4KB) is not enough to store TapFAT driver even in compressed form.
Therefore, the BIOS contains the minimal driver, which finds the file `bootldr.sys` containing the full driver on the cassette, loads it into RAM, and the further operation of the system occurs through this driver.