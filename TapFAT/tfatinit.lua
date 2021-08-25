--[[Compys(TM) TapFAT Driver v1.52
	2021 (C) Compys S&N Systems
	This is a driver for a "Tape File Allocation Table" (or "TapFAT") system 
	It mounts Computronics Streamers as a filesystem, to use with TapFAT tapes
	To prepare new tape use Quick format in "tfattool" utility
]]
local component = require("component")
local tapfat = require("tapfat")
local fs = require("filesystem")
local shell = require("shell")
local unser = require("serialization").unserialize

local args, options = shell.parse(...)

print('╔══════════════════════════════╗')
print('╟───────────[TapFAT]───────────╢')
print('║     TapFAT Driver v1.52      ║')
print('║        Filesystem for        ║')
print('║      Computronics tapes      ║')
print('║ 2021  (c) Compys S&N Systems ║')
print('╚══════════════════════════════╝')

if options.h then
    print("Usage:")
    print("  tfatinit [-u -h]")
    print("Options:")
	print("  -u  unload driver and unmount all drives")
    print("  -h  show this help")
    return
elseif options.u then
	local count = 0
	for k, v in fs.mounts() do
		if k.address:sub(-4) == '-tap' then
			print("Unmounting " .. k.address .. " on " .. v)
			fs.umount(k)
			count = count + 1
		end
	end
	if count == 0 then print('No drives found for unmounting.') end
else
	local count, cfg = 0
	if fs.exists('/etc/tapfat.cfg') then
		local cfgf = io.open('/etc/tapfat.cfg')
		cfg = unser(cfgf:read("*a"))
	end
	for k,v in component.list("tape_drive") do
		if v == "tape_drive" then
			local mntpath = '/mnt/'..k:sub(0,3)
			if table.pack(fs.get(mntpath))[2] ~= mntpath then
			  print("Mounting " .. k .. " to " .. mntpath)
			  local tpr = tapfat.proxy(k)
			  if cfg and cfg[tpr.address] then
				for k2, v2 in pairs(cfg[tpr.address]) do
					tpr.setDriveProperty(k2, v2)
				end
			  end
			  fs.mount(tpr,mntpath)
			  count = count + 1
			end
		end
	end
	if count == 0 then print('No drives found for mounting.') end
end
