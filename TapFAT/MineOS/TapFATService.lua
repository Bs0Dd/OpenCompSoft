local fs = require("filesystem")
local tfat = require("TapFAT")
local system = require("system")
local component = require("component")

local settingsPath = fs.path(system.getCurrentScript())..'Settings.cfg'
local settings = fs.readTable(settingsPath)

if settings then
	for adr, sets in pairs(settings) do
		if component.proxy(adr) and sets.autoMnt then
			local tape = tfat.proxy(adr)
			fs.mount(tape, '/Mounts/'..tape.address..'/')
			tape.setDriveProperty('tabcom', sets.tCom)
			tape.setDriveProperty('stordate', sets.sDate)
		end
	end
end