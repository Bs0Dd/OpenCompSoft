--[[ RemoteDISK NetClient Connector v1.03.
Connector for NetClient Network disks. Make connections to NetServers.
Author: Bs()Dd
]]
local component = require("component")
local computer = require("computer")
local rmdfs = require("rmdfs")
local fs = require("filesystem")
local seriz = require("serialization")
local shell = require("shell")

local args, options = shell.parse(...)

print("RemoteDISK NetClient Connector v1.03\n")

local function hlp()
    print("Usage:")
    print("  rmdmt [-f] <port> <hostname> <login> <password> or <script.cfg>")
    print("Options:")
    print("  -f  read data from script file")
    print("  -h  show this help")
    os.exit()
end

if component.list("modem")() == nil then
    io.stderr:write("No Network Card is detected.")
end

if options.h or args == {} then
    hlp()
end

if not options.f then
    if args[1] == nil or args[2] == nil or args[3] == nil or args[4] == nil then
        hlp()
    end
    print('Connecting to "' .. args[2] .. '", port ' .. args[1])
    local disk, reason = rmdfs.connect(tonumber(args[1]), args[2], args[3], args[4])
    if reason ~= nil then
        io.stderr:write("Connecting error: " .. reason)
    end
    local adr = string.sub(disk.address, 1, 3)
    local _, res = fs.mount(disk, "/mnt/" .. adr)
    if res ~= nil then
        print("Mounting error: " .. res .. ". Skipping...")
    else
        print("Network Disk is mounted to /mnt/" .. adr)
    end
else
    if args[1] == nil then
        hlp()
    end
    local f, reason = io.open(args[1], "r")
    if reason ~= nil then
        io.stderr:write("File opening error: " .. reason)
    end
    local z = f:read(8192)
    local tb = seriz.unserialize(z)
    if tb == nil then
        io.stderr:write("Reading error: incorrect config")
    end
    for name, vals in pairs(tb) do
        print('Connecting to "' .. name .. '", port ' .. vals.port)
        os.sleep(0.0001)
        local disk, reason = rmdfs.connect(vals.port, name, vals.login, vals.password)
        if reason ~= nil then
            print("Connecting error: " .. reason .. ". Skipping...")
        else
            local adr = string.sub(disk.address, 1, 3)
            local _, res = fs.mount(disk, "/mnt/" .. adr)
            if res ~= nil then
                print("Mounting error: " .. res .. ". Skipping...")
            else
                print("Network Disk is mounted to /mnt/" .. adr)
            end
        end
    end
end

