--[[ SecuROM Creator.
Program for creating Password-secured Lua BIOS EEPROM for OpenComputers
Author: Bs()Dd
]]

local function confirm(msg)
    print(msg)
    print("Type `y` to start or `n` to exit.")
    repeat
      local response = io.read()
      if response and response:lower():sub(1, 1) == "n" then
        os.exit()
      end
    until response and response:lower():sub(1, 1) == "y"
  return true
end

local component = require('component')
print('SecuROM Lua BIOS Creator v 1.1')
print('2020 (c) Compys Security Software\n')
confirm("Do You want to set password on Your BIOS?")
print('\nEnter password:')
local passw = io.read()
if confirm("\nAre You ready to flash EEPROM?") then
     code= [=[local init
do
local component_invoke = component.invoke
local function boot_invoke(address, method, ...)
local result = table.pack(pcall(component_invoke, address, method, ...))
if not result[1] then
return nil, result[2]
else
return table.unpack(result, 2, result.n)
end
end
local eeprom = component.list("eeprom")()
computer.getBootAddress = function()
return boot_invoke(eeprom, "getData")
end
computer.setBootAddress = function(address)
return boot_invoke(eeprom, "setData", address)
end
do
local screen = component.list("screen")()
local gpu = component.list("gpu")()
if gpu and screen then
boot_invoke(gpu, "bind", screen)
end
end
local function tryLoadFrom(address)
local handle, reason = boot_invoke(address, "open", "/init.lua")
if not handle then
return nil, reason
end
local buffer = ""
repeat
local data, reason = boot_invoke(address, "read", handle, math.huge)
if not data and reason then
return nil, reason
end
buffer = buffer .. (data or "")
until not data
boot_invoke(address, "close", handle)
return load(buffer, "=init")
end
local reason
if computer.getBootAddress() then
init, reason = tryLoadFrom(computer.getBootAddress())
end
if not init then
computer.setBootAddress()
for address in component.list("filesystem") do
init, reason = tryLoadFrom(address)
if init then
computer.setBootAddress(address)
break
end
end
end
if not init then
error("no bootable medium found" .. (reason and (": " .. tostring(reason)) or ""), 0)
end
computer.beep(1000, 0.2)
end
function pull(...)
local args = table.pack(...)
if type(args[1]) == "string" then
return pullFiltered(createPlainFilter(...))
else
checkArg(1, args[1], "number", "nil")
checkArg(2, args[2], "string", "nil")
return pullFiltered(args[1], createPlainFilter(select(2, ...)))
end
end
function pullFiltered(...)
local args = table.pack(...)
local seconds, filter = math.huge
if type(args[1]) == "function" then
filter = args[1]
else
checkArg(1, args[1], "number", "nil")
checkArg(2, args[2], "function", "nil")
seconds = args[1]
filter = args[2]
end
repeat
local signal = table.pack(computer.pullSignal(seconds))
if signal.n > 0 then
if not (seconds or filter) or filter == nil or filter(table.unpack(signal, 1, signal.n)) then
return table.unpack(signal, 1, signal.n)
end
end
until signal.n == 0
end
function createPlainFilter(name, ...)
local filter = table.pack(...)
if name == nil and filter.n == 0 then
return nil
end
return function(...)
local signal = table.pack(...)
if name and not (type(signal[1]) == "string" and signal[1]:match(name)) then
return false
end
for i = 1, filter.n do
if filter[i] ~= nil and filter[i] ~= signal[i + 1] then
return false
end
end
return true
end
end
function check()
if inp == password then
computer.beep(1000, 0.5)
init()
else
vid.fill(10, 3, mx, 1, " ")
vid.set(1,4, "Incorrect Password!")
inp = ""
pos = 1
computer.beep(500,1)
vid.fill(1, 4, mx, 1, " ")
end
end
vid=component.proxy(component.list("gpu")())
mx, my = vid.getResolution()
vid.fill(1, 1, mx, my, " ")
vid.set(1,1, "SecuROM Lua BIOS v1.0.2")
vid.set(1,2, "2020 (c) Compys Security Software")
computer.beep(2000,0.5)
computer.beep(2000,0.5)
vid.set(1,3, "Password: ")
password = "%s"
inp = ""
pos = 1
while true do
  _, _, key = pull("key_up")
  if key == 8 then
    if pos == 1 then pos = 2 end
    pos= pos-1
    inp = inp:sub(1,pos-1)
    vid.set(pos+10,3, ' ')
  elseif key == 13 then
    check()
  elseif key == 0 or key == 9 or key == 127 then
  else
    pos = pos+1
    inp = inp..unicode.char(key)
    vid.set(pos+9,3, "*")
  end 
end]=]
     local chip = component.eeprom
     chip.set(string.format(code, passw))
     chip.setLabel('SecuROM Lua BIOS')
     print('\nPassword set!')
   end
