--[[ RemoteDISK NetClient DisConnector v1.03.
Connector for NetClient Network disks. Make connections to NetServers.
Author: Bs()Dd
]]
local component = require("component")
local computer = require("computer")
local rmdfs = require("rmdfs")
local fs = require("filesystem")
local seriz= require("serialization")
local shell= require("shell")

local args, options = shell.parse(...)

print('RemoteDISK NetClient DisConnector v1.03')

local function hlp()
  print("Usage:")
  print("  rmdumt [-f -a] <port> or <script.cfg>")
  print("Options:")
  print("  -f  read data from script file")
  print("  -a  Remove any mounts by file system label or address instead of by path. Note that the address may be abbreviated.")
  print("  -h  show this help")
  os.exit()
end

if component.list("modem")() == nil then io.stderr:write("No Network Card is detected.") end

if options.h or args[1] == nil then hlp() end 

if not options.f then
  local proxy, reason
  if options.a then
    proxy, reason = fs.proxy(args[1])
    if proxy then
      proxy = proxy.address
    end
  else
    local path = shell.resolve(args[1])
    proxy, reason = fs.get(path)
    if reason ~= path then
      io.stderr:write("Error: not a mount point\n")
      return 1
    end
  end
  if not proxy then
    io.stderr:write(tostring(reason)..'\n')
    return 1
  end
  if string.sub(proxy.address, -4) ~= '-rfs' then io.stderr:write("Error: not a Network Disk") return 1 end
  ans, err = proxy.disconnect() 
  if ans ~= 'user logged off' then io.stderr:write("Closing error: "..err) return 1
  else
      adr = string.sub(proxy.address,1,3)
      print('Network Disk /mnt/'..adr..' unmounted and component unplugged')
  end
else
  local f, reason = io.open(args[1], 'r')
  if reason ~= nil then io.stderr:write("File opening error: "..reason) return 1 end
  z = f:read(8192)
  tb = seriz.unserialize(z)
  if tb == nil then io.stderr:write("Reading error: incorrect config") return 1 end
  for _, paths in pairs(tb) do
    local proxy, reason
  if options.a then
    proxy, reason = fs.proxy(args[1])
    if proxy then
      proxy = proxy.address
    end
  else
    local path = shell.resolve(args[1])
    proxy, reason = fs.get(path)
    if reason ~= path then
      io.stderr:write("Error: not a mount point\n")
      return 1
    end
  end
  if not proxy then
    io.stderr:write(tostring(reason)..'\n')
    return 1
  end
  if string.sub(proxy.address, -4) ~= '-rfs' then io.stderr:write("Error: not a Network Disk") return 1 end
  ans, err = proxy.disconnect() 
  if ans ~= 'user logged off' then io.stderr:write("Closing error: "..err) return 1
  else
      adr = string.sub(proxy.address,1,3)
      print('Network Disk /mnt/'..adr..' unmounted and component unplugged')
  end
  end
end
