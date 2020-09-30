--[[ stortape program, provides storing and reading data from tapes (with optinal encryption and compression)
Author: Bs()Dd (uses original "tape" program code by Bizzycola and Vexatos)
]]
-- Encryption and compression is disabled in code now
debdump = io.open('dump.bug', 'wb')
local component = require("component")
local fs = require("filesystem")
local shell = require("shell")
local term = require("term")

local args, options = shell.parse(...)

if not component.isAvailable("data") then
  print("Data card is not found in system, AES and Compression not supported.")
  crst = nil
else
  data = component.data 
  if data.encrypt == nil then
    print("Data card Tier 1 is found in system, only Compression supported.")
    crst = false
  else
    print("Data card Tier 2 or 3 is found in system, AES and Compression supported.")
    crst = true
  end
end

local function printUsage()
  print("Usage:")
  print(" - 'stortape -r <start address> <file>' to record file to address in tape")
  print(" - 'stortape -l <start address> <end address> <save to>' to read file from address in tape and save")
  print("Rec & Load options:")
  print(" '--comp' to compression recording chunks (Tier 1 Data card required)")
  print(" '--dcom' to decompression reading chunks (Tier 1 Data card required)")
  print(" '-e' to effective compression by caching data to HDD (Minimum 1Mb free space required)")
  print("      also needs when decompressing effective compressed file")
  print(" '--b=<bytes>' to specify the size of the chunks the program will write to a tape")
  print(" '--eaes=<password>' to encrypt chunks by AES before rec (Tier 2 Data card required)")
  print(" '--daes=<password>' to decrypt chunks by AES before save (Tier 2 Data card required)")
  print(" '--v=<init. vector>' to set custom IV for AES encrypting")
  print(" '--address=<address>' to use a specific tape drive")
  print(" '-y' to not ask for confirmation before starting to write")
  return
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

local function getTapeDrive()
  --Credits to gamax92 for this
  local tape
  if options.address then
    if type(options.address) ~= "string" then
      io.stderr:write("'address' may only be a string.")
      return
    end
    local fulladdr = component.get(options.address)
    if fulladdr == nil then
      io.stderr:write("No component at this address.")
      return
    end
    if component.type(fulladdr) ~= "tape_drive" then
      io.stderr:write("No tape drive at this address.")
      return
    end
    tape = component.proxy(fulladdr)
  else
    tape = component.tape_drive
  end
  return tape
  --End of gamax92's part
end

local tape = getTapeDrive()

local function crypt(mode, bytes, passw, vector)

if mode == true then
local crypted = data.encrypt(bytes, passw, vector)
end
if mode == false then
local crypted = data.decrypt(bytes, passw, vector)
end
return crypted
end

local function binit()
if not tape.isReady() then
    io.stderr:write("Tape is not inserted.\n")
    os.exit()
end
if options.eaes or options.daes then
  if crst == false then
  io.stderr:write("Error: AES is not supported. Install Data card Tier 2\n")
  os.exit()
  else
    if options.eaes ~= nil then
      local passw = options.eaes
    else
      local passw = options.daes
     end
    if string.len(passw) % 16 ~= 0 then
        repeat
          passw = passw .. '_'
        until string.len(passw) % 16 == 0
    end
  end
end
if options.comp or options.dcom then
  if crst == nil then
  io.stderr:write("Error: Compression is not supported. Install Data card\n")
  os.exit()
  else
  print("Compression set.")
  end
end
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
local vect = "stortapevectorbr"
if options.v then
    if string.len(options.v) % 16 ~= 0 then
      vect = options.v
      repeat
        vect = vect .. '_'
      until string.len(vect) % 16 == 0
      print("Setting IV value to " .. vect)
    else
      print("Setting IV value to " .. options.v)
      vect = options.v
    end
end
return block, passw, vect
end

local function inflateb(siz, sav)
_, y = term.getCursor()
local function fancyNumber(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):gsub("%D$", ""):reverse()
  end
local function tapbuff(tbuffer)
  if tbuffer == '' then
    tbuffer = tape.read(8192)
    debdump:write(tbuffer)
  end
  ret = string.sub(tbuffer, 0, 2)
  tbuffer = string.sub(tbuffer, 3)
  if tbuffer == '' then
    tbuffer = tape.read(8192)
    debdump:write(tbuffer)
  end
  ret2 = string.sub(tbuffer, 0, 2)
  tbuffer = string.sub(tbuffer, 3)
  return ret, ret2, tbuffer
end  
local rad = 0
local ncope = 0
local d= tape.read(2)
local tbuffer = tape.read(8192)
debdump:write(tbuffer)
repeat
  re = ''
  ro = ''
  rd = d
  repeat
    re, ro, tbuffer = tapbuff(tbuffer)
    if re == nil or ro == nil then
       re = d
    elseif re == d then 
      rd = rd .. re
      tbuffer = ro .. tbuffer
    elseif string.sub(re, 2) .. string.sub(ro, 0, 1) == d then
      tbuffer = string.sub(ro, 2) .. tbuffer
      ro = d
      rd = rd .. string.sub(re, 0, 1)  
    elseif string.sub(ro, 2) == string.sub(d, 0, 1) then
      rp = string.sub(tbuffer, 0, 1)
      if rp == string.sub(d, 2) then
        rd = rd .. re .. string.sub(ro, 0, 1)
        ro = d
        tbuffer = string.sub(tbuffer, 2)
      else
        rd = rd .. re .. ro
      end
    else
      rd = rd .. re .. ro
    end
    if #rd > siz - rad then
      repeat rd = string.sub(rd, 0, #rd-1)
      until #rd == siz-rad
      re = d
    end
  until re == d or ro == d
  rad = rad + #rd
  term.setCursor(1, y)
  inf, cer = data.inflate(rd) 
  if cer ~= nil then 
        io.stderr:write("Data card error: "..cer..'\n')
        os.exit()
  end
  ncope = ncope + #inf
  term.write(string.format("Write %s byte...", fancyNumber(ncope)))
  sav:write(inf)
until rad >= siz
end

local function record()
  local _, y
  local block, passw, vect = binit()
  tape.stop()
  tape.seek(-tape.getSize())
  tape.seek(tonumber(args[1]))
  tape.stop()
  local path = shell.resolve(args[2])
  size = fs.size(path)
  file, msg = io.open(path, "rb")
  if not file then
    io.stderr:write("Error: " .. msg)
    return
  end
  local free = tape.getSize() - args[1]
  print("Size of tape is: " .. tape.getSize())
  print("Bytes to end: " .. free)
  print("Path of file: " .. path)
  print("Size of file: " .. size)
  local bytery = 0
  local fbytery = 0
  if size > tape.getSize() then
    io.stderr:write("Tape size is not enough to copy.\n")
    os.exit()
  end
  if options.comp or options.eaes then
    if size < tape.getSize() and size > tape.getSize()-2048 then
      if not confirm("Warning: File may not fit on tape after AES/Compression. Continue?") then return end
    end
  end
  
  if not confirm("Are you sure you want to write to this tape?") then return end
  
  local function fancyNumber(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):gsub("%D$", ""):reverse()
  end
  _, y = term.getCursor()
  repeat
    local bytes = file:read(block)
    local cbytes = bytes
    if bytes and #bytes > 0 then
      if not tape.isReady() then
        io.stderr:write("\nError: Tape was removed during writing.\n")
        file:close()
        return
      end
      term.setCursor(1, y)
      bytery = bytery + #bytes
      if options.comp then
        bytes, cer= data.deflate(bytes)
        if cer ~= nil then 
          io.stderr:write("Data card error: "..cer..'\n')
          os.exit()
        end
        fbytery = fbytery + #bytes
      end
      if options.eaes then
        a= ''
      end
      if not options.comp and not options.eaes then local fbytery = bytery end
      print(#bytes)
      print('')
      term.write(string.format("Write %s byte...", fancyNumber(fbytery)))
      tape.write(bytes)
    end
  until not cbytes or bytery > size
  file:close()
  tape.stop()
  tape.seek(-tape.getSize())
  tape.stop()
  print("\nDone. REMIND FILE ADDRESS: " .. args[1] .. " " .. args[1]+fbytery-1)
end

local function lload()
  local _, y
  local block, passw, vect = binit()
  tape.stop()
  tape.seek(-tape.getSize())
  tape.seek(tonumber(args[1]))
  tape.stop()
  local path = shell.resolve(args[3])
  size = args[2]-args[1]+1
  file, msg = io.open(path, "w")
  if not file then
    io.stderr:write("Error: " .. msg)
    return
  end
  print("Size of tape is: " .. tape.getSize())
  print("Path of file: " .. path)
  print("Size of file: " .. size)
  local bytery = 0
  
  if not confirm("Are you sure you want to write to computer?") then return end
  
  local function fancyNumber(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):gsub("%D$", ""):reverse()
  end
  
  if options.dcom then
    inflateb(size, file)
  else
  _, y = term.getCursor()
  local szcut = size
  repeat
    local bytes = tape.read(block)
    if bytes and #bytes > 0 then
      if not tape.isReady() then
        io.stderr:write("\nError: Tape was removed during reading.\n")
        file:close()
        return
      end
      term.setCursor(1, y)
      bytery = bytery + #bytes
      local displaySize = math.min(bytery, size)
      term.write(string.format("Write %s byte...", fancyNumber(bytery)))
      if not bytes or bytery > size then
        cutbytes = string.sub(bytes, 0, szcut)
        file:write(cutbytes)
      else
        file:write(bytes)
        szcut = szcut - block
      end
    end
  until not bytes or bytery > size
  end
  file:close()
  tape.stop()
  tape.seek(-tape.getSize())
  tape.stop()
  print("\nDone. File saved.")
end

if options.r and args[1] and args[2] then
  record()
elseif options.l and args[1] and args[2] and args[3] then
  lload()
else
  printUsage()
end
