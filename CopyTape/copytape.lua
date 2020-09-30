--[[ copytape program, provides copying tapes with two tape drives
Author: Bs()Dd (uses original "tape" program code by Bizzycola and Vexatos)
]]
local component = require("component")
local shell = require("shell")
local term = require("term")

local args, options = shell.parse(...)

if not component.isAvailable("tape_drive") then
  io.stderr:write("Tape drive is not found in system.")
  return
end

local function printUsage()
  print("Usage:")
  print(" - 'copytape adr1 adr2' to copy tape from adr1 tape drive to adr2")
  print(" '--cut' to cut record when second tape is smaller")
  print(" '--b=<bytes>' to specify the size of the chunks the program will write to a tape")
  print(" '-y' to not ask for confirmation before starting to write")
  return
end

local function getTapeDrive()
  --Credits to gamax92 for this
  local tape
  if args[1] then
    if type(args[1]) ~= "string" then
      io.stderr:write("'address' may only be a string.\n")
      return
    end
    local fulladdr = component.get(args[1])
    if fulladdr == nil then
      io.stderr:write("No component at first address.\n")
      return
    end
    if component.type(fulladdr) ~= "tape_drive" then
      io.stderr:write("No tape drive at first address.\n")
      return
    end
    tape = component.proxy(fulladdr)
  else
    io.stderr:write("Primary tape adress is not found.\n")
    return
  end
  return tape
  --End of gamax92's part
end

local function getTapeDriveTwo()
  --Credits to gamax92 for this
  local tape
  if args[2] then
    if type(args[2]) ~= "string" then
      io.stderr:write("'address' may only be a string.\n")
      return
    end
    local fulladdr = component.get(args[2])
    if fulladdr == nil then
      io.stderr:write("No component at second address.\n")
      return
    end
    if component.type(fulladdr) ~= "tape_drive" then
      io.stderr:write("No tape drive at second address.\n")
      return
    end
    tape = component.proxy(fulladdr)
  else
    io.stderr:write("Secondary tape adress is not found.\n")
    return
  end
  return tape
  --End of gamax92's part
end

local function confirm(msg)
  if not options.y then
    print(msg)
    print("Type `y` to confirm, `n` to cancel.")
    repeat
      local response = io.read()
      if response and response:lower():sub(1, 1) == "n" then
        print("Canceled.")
        return false
      end
    until response and response:lower():sub(1, 1) == "y"
  end
  return true
end

local function ctape(tape, tapeTwo)
  local block = 2048
  if options.b then
    local nBlock = tonumber(options.b)
    if nBlock then
      print("Setting chunk size to " .. options.b)
      block = nBlock
    else
      io.stderr:write("option --b is not a number.\n")
      return
    end
  end
  local _, y
  local filesize = tape.getSize()
  if not tape.isReady() then
    io.stderr:write("First tape is not inserted.\n")
    os.exit()
  end
  print("Size of first tape is: " .. tape.getSize())
  if not tapeTwo.isReady() then
    io.stderr:write("Second tape is not inserted.\n")
    os.exit() 
  end
  print("Size of second tape is: " .. tapeTwo.getSize())
  if tape.getSize() > tapeTwo.getSize() and not options.cut then
    io.stderr:write("Second tape size is not enough to copy.\n")
    os.exit()
  end
  if tape.getSize() > tapeTwo.getSize() and options.cut then
    print("Second tape size is not enough to full copy. Record will cut.")
    filesize = tapeTwo.getSize()
  end
  if not confirm("\nAre you sure you want to copy tape?") then return end
  tape.stop()
  tape.seek(-tape.getSize())
  tape.stop()
  tapeTwo.stop()
  tapeTwo.seek(-tapeTwo.getSize())
  tapeTwo.stop()
  local bytery = 0
  print("Copying...")
  _, y = term.getCursor()
  local function fancyNumber(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):gsub("%D$", ""):reverse()
  end
  repeat
  if not tape.isReady() then
        io.stderr:write("\nError: First tape was removed during reading.\n")
	tape.stop()
  	tape.seek(-tape.getSize())
  	tape.stop()
        os.exit()
      end
      if not tapeTwo.isReady() then
        io.stderr:write("\nError: Second tape was removed during writing.\n")
	tape.stop()
  	tape.seek(-tape.getSize())
  	tape.stop()
        os.exit()
      end
  local byte = tape.read(block)
    if byte and #byte > 0 then
      term.setCursor(1, y)
      bytery = bytery + #byte
      local displaySize = math.min(bytery, filesize)
      term.write(string.format("Copy %s of %s bytes... (%.2f %%)", fancyNumber(displaySize),    fancyNumber(filesize), 100 * displaySize / filesize))
      tapeTwo.write(byte)
    end
  until not byte or bytery > filesize
  tape.stop()
  tape.seek(-tape.getSize())
  tape.stop()
  tapeTwo.stop()
  tapeTwo.seek(-tapeTwo.getSize())
  tapeTwo.stop()
  tapeTwo.setLabel(tape.getLabel())
  print("\nDone.")
end

if args[1] ~= nil and args[2] ~= nil then
  local tape = getTapeDrive()
  if tape == nil then
    os.exit()
  end
  local tapeTwo = getTapeDriveTwo()
  if tapeTwo == nil then
    os.exit()
  end
  ctape(tape, tapeTwo)
else
  printUsage()
end
