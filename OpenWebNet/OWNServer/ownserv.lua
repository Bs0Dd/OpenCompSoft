local component = require("component")
local seriz = require("serialization")
local event = require("event")
local fs = require("filesystem")
local piclib = require("image")

local function split(inp, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inp, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local function request(_, _, from, _, _, mess, mess2)
	if mess == 'GPG' then
		ifok = ''
		sects = split(mess2, '/')
		if mess2 == nil or mess2 == "" then
			mess2 = 'index.nfp'
			ifok = 'i'
			sects[1]= 'index.nfp'
		end
		if split(sects[#sects], '.')[2]:lower() ~= "nfp" then
			mess2 = fs.concat(mess2, 'index.nfp')
			ifok = 'i'
		end
		if not fs.exists(fs.concat(args, mess2)) then
			card.send(from, 3707, '404') 
			return
		end
		rawpage = io.open(fs.concat(args, mess2))
		sended = 0
      		remain = fs.size(fs.concat(args, mess2))
      		card.send(from, 3707, ifok..'FOK')
      		if remain > 8000 then bread = 8000 else bread = remain end
      			while sended < fs.size(fs.concat(args, mess2)) do
        			rdd = rawpage:read(bread)
        			if rdd == nil then rdd = '' end
        			card.send(from, 3707, 'FTR', rdd)
        			sended = sended + 8000
        			remain = remain - 8000
        			if remain < 8000 then bread = remain end
      			end
		card.send(from, 3707, "FEND")
		rawpage:close()
	elseif mess == 'GFL' then
		if not fs.exists(fs.concat(args, mess2)) then
			card.send(from, 3707, '404') 
			return
		end
		rawpage = io.open(fs.concat(args, mess2))
		sended = 0
      		remain = fs.size(fs.concat(args, mess2))
      		card.send(from, 3707, ifok..'FOK')
      		if remain > 8000 then bread = 8000 else bread = remain end
      			while sended < fs.size(fs.concat(args, mess2)) do
        			rdd = rawpage:read(bread)
        			if rdd == nil then rdd = '' end
        			card.send(from, 3707, 'FTR', rdd)
        			sended = sended + 8000
        			remain = remain - 8000
        			if remain < 8000 then bread = remain end
      			end
		card.send(from, 3707, "FEND")
		rawpage:close()
	elseif mess == 'GIM' then
		if not fs.exists(fs.concat(args, mess2)) then
			card.send(from, 3707, '404') 
			return
		end
		pictabl = piclib.load(fs.concat(args, mess2))
		ptabser = piclib.toString(pictabl)
		sended = 0
      		remain = #ptabser
      		card.send(from, 3707, 'FOK')
      		if remain > 8000 then bread = 8000 else bread = remain end
      			while sended < #ptabser do
        			rdd = string.sub(ptabser, sended+1, sended+8000)
        			card.send(from, 3707, 'FTR', rdd)
        			sended = sended + 8000
        			remain = remain - 8000
        			if remain < 8000 then bread = remain end
      			end
		card.send(from, 3707, "FEND")
	end
end

function start()
	if work == nil then
		if component.list("modem")() == nil then io.stderr:write("No Network Card is detected.") return end
		card = component.proxy(component.list("modem")())
		work = true
		print("OWN Web-Site Server v0.15")
		card.open(3707)
		if args == nil then
			io.stderr:write("FATAL ERROR! Web-site dir isn't set!")
			return end
		if not fs.exists(args) then
			io.stderr:write("FATAL ERROR! Web-site dir isn't exists!")
			return
		else
			print("Initialization OK. Set dir: "..args) end
		local work = true
		event.listen("modem_message", request)
	else
		io.stderr:write("Server already started!")
	end
end

function stop()
	if work == true then
		work = nil
		print("Server stopped.")
		event.ignore("modem_message", request)
		card.close(3707)
	else
		io.stderr:write("Server isn't working now!")
	end
end
