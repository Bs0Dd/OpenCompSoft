component = require("component")
term = require("term")
seriz = require("serialization")
fs = require("filesystem")
ev = require("event")
unicode = require("unicode")

vid = component.gpu

local line = false;
local lfil = true;

function drawpage(rx, ry, sbk)
	pos = 0
	mx, my = vid.getResolution()
	vid.setBackground(sbk)
  	vid.setForeground(0xFFFFFF)
  	vid.fill(1,1,mx,my, " ")
	while pos ~= #page do
		pos= pos+1
		if page[pos][1] == 0 then
			if conf["autobackg"] == true and page[pos][5] == 0x000000 then
				vid.setBackground(sbk)
			else
				vid.setBackground(page[pos][5])
			end
			vid.setForeground(page[pos][4])
			vid.set(page[pos][2]+rx, page[pos][3]+ry, page[pos][6])
		end
	end
	
end

function drawplate(pnam, ofon, lf)
	mx, my = vid.getResolution()
	vid.setForeground(0x000000)
  	vid.setBackground(0xFFFFFF)
  	vid.fill(1,my,mx,my, " ")
  	vid.set(2, my, "Memphisto OWP Browser v0.01a")
  	if lf == true then
  		vid.set(36, my, "Page: "..pnam)
  	else
  		vid.set(36, my, "Page: "..fs.name(pnam))
  	end
  	if ofon == true then
  		vid.setBackground(0x00FF00)
  		vid.set(mx-7, my, "ON-LINE")
  	else
  		vid.setBackground(0xFF0000)
  		vid.set(mx-8, my, "OFF-LINE")
  	end
  	vid.setBackground(0x000000)
  	vid.setForeground(0xFFFFFF)
end

function prac()
	print("Press any key to continue.")
	ev.pull("key_down")
end

function setline()
	term.clear()
	drawplate(padd, line)
	if component.list("modem")() == nil then 
	print("No Network Card is detected.\nYou can't use ON-LINE mode!") prac() return end
	card = component.proxy(component.list("modem")())
	card.open(3707)
	if line == false then
		if conf["DDBS_uselocal"] == true then
			f, res = io.open(conf["DDBS_local"])
			if f == nil then
				print("FATAL ERROR! Can't open local DDBServer file!") prac() return end
			servs = seriz.unserialize(f:read())
			if servs == nil then
				print("FATAL ERROR! Can't handle local DDBServer file!") prac() return end
			line = true
				print("OK! Now you are ON-LINE") drawplate(padd, line) os.sleep(1,5)	
		else
			print("Connecting to DDBServer on "..conf["DDBS_serv"])
			card.send(conf["DDBS_serv"], 3707, 'GADL')
			_, _, _, _, _, message = ev.pull(5, "modem_message")
			if message == nil then
				print("FATAL ERROR! No answer from server!") prac()
			else
				servs = seriz.unserialize(message)
				if servs == nil then
					print("FATAL ERROR! Can't handle remote DDBServer file!") prac() return end
				line = true
				print("OK! Now you are ON-LINE") drawplate(padd, line) os.sleep(1,5)
			end
		end
	else
		line = false
		print("OK! Now you are OFF-LINE") drawplate(padd, line) os.sleep(1,5)
	end
end

function split(inp, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inp, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function restore(table)
        res = ''
        for _, val in pairs(table) do
        	res = res..'/'..val
        end
        return res
end

function openpage()
	if inp == "" then return end
	vid.setBackground(0x000000)
  	vid.setForeground(0xFFFFFF)
	term.clear()
	drawplate(padd, line)
	print("Opening page: "..inp)
	if line == true then
		parts = split(inp, "/")
		opp = servs[parts[1]]
		if opp == nil then
			padd = "/usr/misc/noserver.nfp"
			rawpage = io.open(padd)
			page = seriz.unserialize(rawpage:read())
			return
		end
		print("Server address found in DB, connecting...")
		parts[1] = nil
		rpath = restore(parts)
		card.send(opp, 3707, "GPG", rpath)
		_, _, _, _, _, message = ev.pull(5, "modem_message")
		if message == nil then
				padd = "/usr/misc/noanswer.nfp"
				rawpage = io.open(padd)
				page = seriz.unserialize(rawpage:read())
				return
		end
		print("Connected, getting page...")
		
	else
		padd = inp
		rawpage = io.open(inp)
		if rawpage == nil then
			padd = "/usr/misc/404.nfp"
			rawpage = io.open(padd)
			page = seriz.unserialize(rawpage:read())
			return
		end
		page = seriz.unserialize(rawpage:read())
		if page == nil then
			padd = "/usr/misc/incorrect.nfp"
			rawpage = io.open(padd)
			page = seriz.unserialize(rawpage:read())
			return
		end
	end
end

function enterurl()
	mx, my = vid.getResolution()
	vid.setBackground(0x5A5A5A)
	vid.setForeground(0x000000)
	vid.fill(42, my, mx, 1, " ")
	inp = ''
	pos = 1
	while true do
		eve,_,key = ev.pull()
		if eve == "key_down" then
		if key == 8 then
    			if pos == 1 then pos = 2 end
    			pos= pos-1
    			inp = inp:sub(1,pos-1)
    			vid.set(pos+42,my, ' ')
  		elseif key == 13 then
    			openpage()
    			return
  		else
    			pos = pos+1
    			inp = inp..unicode.char(key)
    			vid.set(pos+41,my, unicode.char(key))
    		end
	elseif eve == "interrupted" then return end
end
end

function gohome()
	padd = conf["homepage"]
	rawpage = io.open(conf["homepage"])
	page = seriz.unserialize(rawpage:read())
end

rawconf = io.open("/etc/webbrow.cfg")
conf = seriz.unserialize(rawconf:read())
if conf == nil then
	print("FATAL ERROR! Can't handle config file!") return end
padd = conf["homepage"]
rawpage = io.open(conf["homepage"])
page = seriz.unserialize(rawpage:read())
if page == nil then
	print("FATAL ERROR! Can't handle homepage file!") return end

rx=0
ry=0

drawpage(rx, ry, conf["std_backg"])
drawplate(conf["homepage"], line)

while true do
	eve,_,_,key = ev.pull()
	if eve == "key_down" then
		if key == 200 then ry= ry+1
		elseif key == 208 then ry= ry-1
			elseif key == 203 then rx= rx+1
			elseif key == 205 then rx= rx-1 
			elseif key == 67 then setline() 
			elseif key == 59 then gohome()
		elseif key == 62 then enterurl() end
		if rx > 0 then rx = 0 end
		if ry > 0 then ry = 0 end
		drawpage(rx, ry, conf["std_backg"])
		drawplate(padd, line)
	elseif eve == "interrupted" then
		if line == true then card.close(3707) end
		term.clear()
		os.exit()
	end
end
