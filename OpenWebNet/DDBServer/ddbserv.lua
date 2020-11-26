local component = require("component")
local seriz = require("serialization")
local event = require("event")

local function request(_, _, from, _, _, mess)
	if mess == 'GADL' then
		local retn, orber = seriz.serialize(args)
		card.send(from, 3707, retn)
	end
end

function start()
	if work == nil then
		if component.list("modem")() == nil then io.stderr:write("No Network Card is detected.") return end
		card = component.proxy(component.list("modem")())
		work = true
		print("OWP Domens DataBase Server v0.2")
		card.open(3707)
		local totl = 0
		for k,v in pairs(args) do
  			totl = totl + 1
  		end
		if totl == 0 then
			print("FATAL ERROR! No entries found!")
			return
		else
			print("Initialization OK. Found "..totl.." entries") end
		local work = true
		event.listen("modem_message", request)
	end
end

function stop()
	local work = nil
	event.ignore("modem_message", request) 
end
