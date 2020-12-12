--[[ RemoteDISK NetClient DisConnector v1.03.
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

print("RemoteDISK NetClient DisConnector v1.03\n")

local function hlp()
    print("Usage:")
    print("  rmdumt [-f -a -l -r] <path/address> or <script file>")
    print("Options:")
    print("  -f  read data from script file")
    print("  -a  Remove any mounts by file system label or address instead of by path.")
    print("      Note that the address may be abbreviated.")
    print("  -l  disconnect all network disks")
    print("  -r  force disconnect (will unmount even if the server didn't respond)")
    print("  -h  show this help")
    os.exit()
end

local function do_unmount(proxy, ifnoresp)
    local ans, err = proxy.disconnect()
    if ans ~= "user logged off" then
        if err ~= "You aren't logged in" and ifnoresp == nil then
            io.stderr:write("Closing error: " ..err..'\n')
            return 1
        else
            local adr = string.sub(proxy.address, 1, 3)
            fs.umount(proxy)
            print("Network Disk /mnt/" .. adr .. " unmounted")
        end
    else
        local adr = string.sub(proxy.address, 1, 3)
        fs.umount(proxy)
        print("Network Disk /mnt/" .. adr .. " unmounted")
    end
end

if component.list("modem")() == nil then
    io.stderr:write("No Network Card is detected.\n")
end

if options.h or (args[1] == nil and not options.l) then
    hlp()
end

if not options.f and not options.l then
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
        io.stderr:write(tostring(reason) .. "\n")
        return 1
    end
    if string.sub(proxy.address, -4) ~= "-rfs" then
        io.stderr:write("Error: not a Network Disk\n")
        return 1
    end
    do_unmount(proxy, options.r)
elseif options.l then
    for proxy, _ in fs.mounts() do
        if string.sub(proxy.address, -4) == "-rfs" then
            do_unmount(proxy, options.r)
        end
    end
else
    local f, reason = io.open(args[1], "r")
    if reason ~= nil then
        io.stderr:write("File opening error: " ..reason..'\n')
        return 1
    end
    local z = f:read(8192)
    local tb = seriz.unserialize(z)
    if tb == nil then
        io.stderr:write("Reading error: incorrect config\n")
        return 1
    end
    local paths
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
            io.stderr:write(tostring(reason) .. "\n")
            return 1
        end
        if string.sub(proxy.address, -4) ~= "-rfs" then
            io.stderr:write("Error: not a Network Disk\n")
            return 1
        end
        do_unmount(proxy, options.r)
    end
end

