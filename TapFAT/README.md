# TapFAT Filesystem

TapFAT - Filesystem for cassettes from the Computronics mod.  
With it, you can use the cassette as a storage device like a hard disk or a floppy disk.  
Please note that FS is very slow and was intended as a means of archiving files to tape.

**WARNING!!! Version 1.50+ is incompatible with 1.01, so before updating, you should transfer the data from the cassettes and then format them with the new version.**

## Disclaimer

**WARNING!!! The filesystem is a very complex thing. Although I have tried to catch most of the bugs, their complete absence is not guaranteed. Therefore, I am not responsible for damage to files on the cassette, you act at your own peril and risk.**

## How it works

The first 8KB on the cassette are allocated for the file table, which is a serialized Lua table (I decided not to encode it, since encode/decode will slow down the system even more).
It stores information about free blocks, files (name, size, modification date, belonging to blocks).
The driver uses the table to find the blocks of the file (the system supports fragmentation) and reads them.
Memory for writing is allocated by free blocks recorded in the table.
For basic needs, a standard table is sufficient, but if you want to store more files, it can be compressed programmatically (via LZSS) or hardware (via Data Card), but this will affect the speed of work.

## Specifications

* Number of files: limited only by the size allocated for the table. With a table in 8KB:
	* Uncompressed - ~150 files
	* LZSS compression - ~580 files
	* Data Card Compression - ~720 files
* Block Size: Arbitrary
* Medium Size: Unlimited
* Fragmentation: Supported

## Installation

1. Run Installer by command `pastebin run Tq3hbpaz`
2. Install driver files
3. Type `tfatinit` to initialize driver
4. Drives will be mount as filesystems
5. It is recommended to write the driver to the autorun file `.shrc` (by entering the line `tfatinit` there) to load it automatically

![Driver](https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/TapFAT/Pictures/driver.png)

## Prepare Tape

The cassette must be formatted before use.

1. Run the `tfattool` program
2. Select `Format tape`
3. Select `Quick format`
4. Сonfirm formatting
5. The cassette is now ready for recording

![Tool](https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/TapFAT/Pictures/tool.png)

The `tfattool` program also allows you to change the cassette name, view basic information, change parameters and selectively unmount tape drives.  
While there are two parameters available: compress the table and save the modified date of files. Disabling saving dates, as well as compressing the table, allows you to fit more files into the table.

## API

In addition to the standard filesystem API, the driver provides several additional functions.

### proxy.**isReady**(): *boolean* ready

Returns true if the drive is ready (tape inserted), false otherwise.

### proxy.**getTable**(): *table* fat

Returns the file allocation table read from the cassette. Creates an error if unsuccessful.

### proxy.**setTable**( fat )

| Type | Parameter | Description |
| ------ | ------ | ------ |
| *table* | fat | File allocation table |

Writes the file allocation table to the cassette. Creates an error if unsuccessful.

### proxy.**format**( fast )

| Type | Parameter | Description |
| ------ | ------ | ------ |
| *boolean* | fast | Fast formatting (only table) |

Erases the entire contents of the cassette or just the table. Full formatting can take a long time.

### proxy.**getDriveProperty**( property ): *any* value

| Type | Parameter | Description |
| ------ | ------ | ------ |
| *string* | property | Property name |

Returns the value of the drive property, if it exists.

### proxy.**setDriveProperty**( property, value )

| Type | Parameter | Description |
| ------ | ------ | ------ |
| *string* | property | Property name |
| *any* | value | Value for property |

Sets the new value for the drive property, if it exists.

### Drive Properties

| Name | Possible values | Description |
| ------ | ------ | ------ |
| **tabcom** | *false*, *1* or *2* | Type of table compression. *False* is compression off, *1* is LZSS, *2* is Data Card |
| **stordate** | *false* or *true* | Store date of files. *False* is off (date will be 0, i.e. 00:00:00, 1 Jan 1970), *true* is on |

## DiskTape Lua BIOS

Read [this text](https://github.com/Bs0Dd/OpenCompSoft/blob/master/TapFAT/DiskTape/README.md).

## Changelog

* Version 1.54
	* Fixed bug when lastModified("") returned a *nil*.
	* Fixed bug with clear tapes.
* Version 1.52
	* Fixed critical bug in makeDirectory function.
	* Fixed critical bug in remove function (when removing directories).
* Version 1.50
	* First version for MineOS
	* Changed file blocks structure, so **this version is not compatible with the previous one**.
	* Fixed critical bug in drive properties.
	* Some small fixes.
* Version 1.01
	* First public version.
