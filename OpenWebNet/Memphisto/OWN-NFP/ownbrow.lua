_VER_ = "0.08c"

local component = require("component")
local tty = require("tty")
local seriz = require("serialization")
local fs = require("filesystem")
local ev = require("event")
local unicode = require("unicode")

local vid = component.gpu


local function globalnil()
	line = nil
	lfil = nil
	ocifs = nil
	refs = nil
	dwrefs = nil
	padd = nil
	lpadd = nil
	picrnd = nil
	conf = nil
	page = nil
	rx = nil
	ry = nil
	why = nil
	hoh = nil
end

line = false
lfil = true
ocifs = {}
refs = {}
dwrefs = {}
padd = ''
lpadd = ''
picrnd = true
conf = {}
page = {}
rx = 0
ry = 0
hoh = true
	
print("Memphisto OWN-NFP v".._VER_)
print("Developing © 2020 Compys S&N Systems")
print("Loading OCIF library...")

local piclib = require("image")
local color = require("color")

local function prac()
	print("Press any key to continue.")
	ev.pull("key_down")
end

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

local function restore(table)
        res = ''
        for _, val in pairs(table) do
        	res = res..val..'/'
        end
        return res:sub(0, -2)
end

local function goerr(mode)
	local opn
	if mode == 0 then
		opn = "/usr/misc/Memphisto/incorrect.nfp"
	elseif mode == 1 then
		opn = "/usr/misc/Memphisto/noserver.nfp"
	elseif mode == 2 then
		opn = "/usr/misc/Memphisto/noanswer.nfp"
	elseif mode == 3 then
		opn = "/usr/misc/Memphisto/404.nfp"
	end
	local rawpage, why = io.open(opn)
	if rawpage == nil then
		tty.clear()
		globalnil()
		print("FATAL ERROR! Can't open system page file: "..why) os.exit() end
	page, why = seriz.unserialize(rawpage:read())
	if page == nil then
		tty.clear()
		globalnil()
		print("FATAL ERROR! Can't handle system page file: "..why) os.exit() end
	lab = page['label']
	rx = 0
	ry = 0
	rawpage:close()
end 

local function drawocif(kx, ky, ptox, locl)
	if padd ~= lpadd then ocifs = {} lpadd = padd end
	parts = split(ptox, "/")
	if parts[1] == ".." then
		parts2 = split(padd, "/")
		parts[1]= parts2[1]
		ptox = restore(parts)
	end
	if picrnd == false then
			vid.setBackground(conf.std_backg)
			vid.setForeground(0xFF0000)
			vid.set(kx, ky, "PICTURE: "..ptox)
			return
	end
	if locl == false then
		if ocifs[ptox] ~= nil then
			piclib.draw(kx,ky,ocifs[ptox])
		else
			parts = split(ptox, "/")
			opp = servs[parts[1]:lower()]
			if opp == nil then
				vid.setBackground(conf.std_backg)
				vid.setForeground(0xFF0000)
				vid.set(kx, ky, "ERROR: No server found for picture")
				return
			end
			parts[1] = nil
			ratd = restore(parts)
			card.send(opp, 3707, "GIM", ratd)
			_, _, _, _, _, mess, mess2 = ev.pull(5, "modem_message")
			if mess == nil then
				vid.setBackground(conf.std_backg)
				vid.setForeground(0xFF0000)
				vid.set(kx, ky, "ERROR: No answer from server")
				return
			elseif mess == 'FOK' then
				rpage = ''
				while mess ~= "FEND" do
					_, _, _, _, _, mess, mess2 = ev.pull(5, "modem_message")
					if mess == "FTR" then
						rpage = rpage..mess2
					end
				end
				pic = piclib.fromString(rpage)
				if ocifs[ptox] == nil then ocifs[ptox] = pic end
				piclib.draw(kx,ky,pic)
			elseif mess == '404' then
				vid.setBackground(conf.std_backg)
				vid.setForeground(0xFF0000)
				vid.set(kx, ky, "ERROR: Picture no found on server")
				return
			end
		end
	else
		if ocifs[ptox] ~= nil then
			piclib.draw(kx,ky,ocifs[ptox])
			return
		end
		pic, why = piclib.load(ptox)
		if pic == false then
			vid.setBackground(conf.std_backg)
			vid.setForeground(0xFF0000)
			if why ~= nil then
				vid.set(kx, ky, "ERROR: Can't load picture: "..why)
			else
				vid.set(kx, ky, "ERROR: Can't load picture: unknown reason")
			end
			return
		end
		if ocifs[ptox] == nil then ocifs[ptox] = pic end
		piclib.draw(kx,ky,pic)
	end
end

local function drawpage(rx, ry, sbk)
	refs = {}
	dwrefs = {}
	pos = 0
	mx, my = vid.getResolution()
	vid.setBackground(sbk)
  	vid.setForeground(0xFFFFFF)
  	vid.fill(1,1,mx,my, " ")
	while pos ~= #page do
		pos= pos+1
		if page[pos][1] == 0 then
			if conf.autobackg == true and page[pos][5] == 0x000000 then
				vid.setBackground(sbk)
			else
				vid.setBackground(page[pos][5])
			end
			vid.setForeground(page[pos][4])
			vid.set(page[pos][2]+rx, page[pos][3]+ry, page[pos][6])
		elseif page[pos][1] == 1 then
			if conf.autobackg == true and page[pos][5] == 0x000000 then
				vid.setBackground(sbk)
			else
				vid.setBackground(page[pos][6])
			end
			vid.setForeground(page[pos][5])
			vid.set(page[pos][2]+rx, page[pos][3]+ry, page[pos][7])
			table.insert(refs, {page[pos][2]+rx, page[pos][2]+rx+#page[pos][7],
			page[pos][3]+ry, page[pos][4], page[pos][8]})
		elseif page[pos][1] == 2 then
			if conf.autobackg == true and page[pos][5] == 0x000000 then
				vid.setBackground(sbk)
			else
				vid.setBackground(page[pos][6])
			end
			vid.setForeground(page[pos][5])
			vid.set(page[pos][2]+rx, page[pos][3]+ry, page[pos][7])
			table.insert(dwrefs, {page[pos][2]+rx, page[pos][2]+rx+#page[pos][7],
			page[pos][3]+ry, page[pos][4], page[pos][8]})
		elseif page[pos][1] == 3 then
			drawocif(page[pos][2]+rx, page[pos][3]+ry, page[pos][5] ,page[pos][4])
		end
	end
end

local function drawplate(pnam, ofon, lf, lab)
	mx, my = vid.getResolution()
	vid.setForeground(0x000000)
  	vid.setBackground(0xFFFFFF)
  	vid.fill(1,my,mx,1, " ")
  	vid.set(2, my, "Memphisto OWN-NFP v".._VER_)
  	tform = ''
  	if lab ~= nil and lab ~= '' then tform = ' - '..lab end
  	if lf == false then
  		vid.set(36, my, "Page: "..pnam..tform)
  	else
  		vid.set(36, my, "Page: "..lab)
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

local function setline()
	tty.clear()
	drawplate(padd, line, lfil, lab)
	if line == false then
		if component.list("modem")() == nil then 
		print("No Network Card is detected.\nYou can't use ON-LINE mode!") prac() return end
		card = component.proxy(component.list("modem")())
		card.open(3707)
		if conf["DDBS_uselocal"] == true then
			f, res = io.open(conf["DDBS_local"])
			if f == nil then
				print("CRITICAL ERROR! Can't open local DDBServer file!") prac() return end
			servs = seriz.unserialize(f:read())
			if servs == nil then
				print("CRITICAL ERROR! Can't handle local DDBServer file!") prac() return end
			line = true
				print("OK! Now you are ON-LINE") drawplate(padd, line, lfil, lab) os.sleep(1,5)	
		else
			print("Connecting to DDBServer on "..conf["DDBS_serv"])
			card.send(conf["DDBS_serv"], 3707, 'GADL')
			_, _, _, _, _, message = ev.pull(5, "modem_message")
			if message == nil then
				print("CRITICAL ERROR! No answer from server!") prac()
			else
				servs = seriz.unserialize(message)
				if servs == nil then
					print("CRITICAL ERROR! Can't handle remote DDBServer file!") prac() return end
				line = true
				print("OK! Now you are ON-LINE") drawplate(padd, line, lfil, lab) os.sleep(1,5)
			end
		end
	else
		line = false
		print("OK! Now you are OFF-LINE") drawplate(padd, line, lfil, lab) os.sleep(1,5)
	end
end

local function openpage(inp, loca)
	if inp == "" then return page end
	if loca == nil then loca = not line end
	parts = split(inp, "/")
	if parts[1] == ".." then
		parts2 = split(padd, "/")
		parts[1]= parts2[1]
		inp = restore(parts)
	end
	rx = 0
	ry = 0
	hoh = false
	lfil = true
	vid.setBackground(0x000000)
  	vid.setForeground(0xFFFFFF)
	tty.clear()
	drawplate(padd, line, lfil, lab)
	print("Opening page: "..inp)
	if loca == false then
		padd = inp
		parts = split(inp, "/")
		opp = servs[parts[1]:lower()]
		if opp == nil then
			goerr(1)
			return
		end
		print("Server address found in DB, connecting...")
		parts[1] = nil
		ratd = restore(parts)
		card.send(opp, 3707, "GPG", ratd)
		_, _, _, _, _, mess, mess2 = ev.pull(5, "modem_message")
		if mess == nil then
			goerr(2)
			return
		elseif mess == 'FOK' then
			print("Connected, getting page...")
			rpage = ''
			while mess ~= "FEND" do
				_, _, _, _, _, mess, mess2 = ev.pull(5, "modem_message")
				if mess == "FTR" then
					rpage = rpage..mess2
				end
			end
			page = seriz.unserialize(rpage)
			if page == nil then
				goerr(0)
				return
			end
		elseif mess == 'iFOK' then
			print("Connected, getting page...")
			padd = fs.concat(padd, 'index.nfp')
			rpage = ''
			while mess ~= "FEND" do
				_, _, _, _, _, mess, mess2 = ev.pull(5, "modem_message")
				if mess == "FTR" then
					rpage = rpage..mess2
				end
			end
			page = seriz.unserialize(rpage)
			if page == nil then
				goerr(0)
				return 
			end
		elseif mess == '404' then
			goerr(3)
			return end
		if page['label'] ~= nil then lab = page['label'] else lab = '' end
		lfil = false
		return 
	else
		padd = inp
		rawpage = io.open(inp)
		if rawpage == nil then
			goerr(3)
			return
		end
		page = seriz.unserialize(rawpage:read())
		if page == nil then
			goerr(0)
			return
		end
		if page['label'] ~= nil then lab = page['label'] else lab = '' end
		lfil = fals
		rawpage:close()
		return
	end
end

local function enterurl()
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
  				lfil = true
    				openpage(inp, not line)
    				return
    			elseif key == 0 or key == 9 or key == 127 then
  			else
    				pos = pos+1
    				inp = inp..unicode.char(key)
    				vid.set(pos+41,my, unicode.char(key))
    			end
		elseif eve == "interrupted" then return page
		elseif eve == "clipboard" then 
			inp = inp..key
			vid.set(pos+42,my, key)
			pos = pos + unicode.len(key)
		end
	end
end

local function gohome()
	padd = conf["homepage"]
	local rawpage, why = io.open(padd)
	if rawpage == nil then
		tty.clear()
		globalnil()
		print("FATAL ERROR! Can't open homepage file: "..why) os.exit() end
	page, why = seriz.unserialize(rawpage:read())
	if page == nil then
		tty.clear()
		globalnil()
		print("FATAL ERROR! Can't handle homepage file: "..why) os.exit() end
	if page['label'] ~= nil then lab = page['label'] else lab = '' end
	lfil = true
	rawpage:close()
	rx = 0
	ry = 0
	hoh = true
end

local function helpmepls()
	padd = '/usr/misc/Memphisto/help.nfp'
	local rawpage, why = io.open(padd)
	if rawpage == nil then
		tty.clear()
		globalnil()
		print("FATAL ERROR! Can't open system page file: "..why) os.exit() end
	page, why = seriz.unserialize(rawpage:read())
	if page == nil then
		tty.clear()
		globalnil()
		print("FATAL ERROR! Can't handle system page file: "..why) os.exit() end
	if page['label'] ~= nil then lab = page['label'] else lab = '' end
	lfil = true
	rawpage:close()
	rx = 0
	ry = 0
	hoh = true
end

local function reload()
	rx = 0
	ry = 0
	ocifs = {}
	if hoh == true then openpage(padd, true) hoh = true
	else openpage(padd, loca) end
end

local function paradraw()
	if clcor == true then
		rx = 0
		ry = 0
	end
	drawpage(rx, ry, conf["std_backg"])
	drawplate(padd, line, lfil, lab)
end

local function download(loca, dwp)
	if loca == nil then loca = not line end
	tty.clear()
	drawplate(padd, line, lfil, lab)
	if loca == false then
		parts = split(dwp, "/")
		if parts[1] == ".." then
			parts2 = split(padd, "/")
			parts[1]= parts2[1]
			dwp = restore(parts)
		end
		print('Do you want to download file: '..parts[#parts]..'? Y/N')
		while true do
			_, _, _, key = ev.pull("key_up")
			if key == 21 then break
			elseif key == 49 then paradraw() return end
		end
		opp = servs[parts[1]:lower()]
		if opp == nil then
			print("ERROR: No server found for file")
			prac()
			return
		end
		parts[1] = nil
		ratd = restore(parts)
		print("Downloading file...")
		card.send(opp, 3707, "GFL", ratd)
		_, _, _, _, _, mess, mess2 = ev.pull(5, "modem_message")
		if mess == nil then
			print("ERROR: No answer from server")
			prac()
			return
		elseif mess == 'FOK' then
			savto = fs.concat(conf.download_dir, parts[#parts])
			sav = io.open(savto, 'wb')
			while mess ~= "FEND" do
				_, _, _, _, _, mess, mess2 = ev.pull(5, "modem_message")
				if mess == "FTR" then
					sav:write(mess2)
				end
			end
			sav:close()
			print("File downloaded!")
			prac()
			paradraw()
		elseif mess == '404' then
			print("ERROR: File no found on server")
			prac()
			return 
			end
	else
		fil = io.open(dwp, 'rb')
		parts = split(dwp, "/")
		print('Do you want to download file: '..parts[#parts]..'? Y/N')
		while true do
			_, _, _, key = ev.pull("key_up")
			if key == 21 then break
			elseif key == 49 then return end
		end
		print("Downloading file...")
		savto = fs.concat(conf.download_dir, parts[#parts])
		sav = io.open(savto, 'wb')
		rded = fil:read()
		while rded ~= nil do
			sav:write(rded)
			rded = fil:read()
		end
		fil:close()
		sav:close()
		print("File downloaded!")
		prac()
		paradraw()
	end
end

local function clickop(kx, ky)
	if #refs ~= 0 or #dwrefs ~= 0 then
		for _, ref in pairs(refs) do
			if ky == ref[3] and ref[1] <= kx and kx <= ref[2]-1 then
				local inp = ref[5]
				openpage(inp, ref[4])
				rx=0
				ry=0
				drawpage(rx, ry, conf["std_backg"])
				drawplate(padd, line, lfil, lab)
			end
		end
		for _, dref in pairs(dwrefs) do
			if ky == dref[3] and dref[1] <= kx and kx <= dref[2]-1 then
				download(dref[4], dref[5])
				return
			end
		end
	end
end

local function offpic()
	if picrnd == true then picrnd = false
	else picrnd = true end
end


local rawconf, why = io.open("/etc/webbrow.cfg")
if rawconf == nil then
	print("FATAL ERROR! Can't open config file: "..why) return end
conf, why = seriz.unserialize(rawconf:read())
rawconf:close()
if conf == nil then
	print("FATAL ERROR! Can't handle config file: "..why) return end
padd = conf["homepage"]
local rawpage, why = io.open(conf["homepage"])
if rawpage == nil then
	print("FATAL ERROR! Can't open homepage file: "..why) return end
page, why = seriz.unserialize(rawpage:read())
if page == nil then
	print("FATAL ERROR! Can't handle homepage file: "..why) return end
if page['label'] ~= nil then lab = page['label'] else lab = '' end
rawpage:close()


drawpage(rx, ry, conf["std_backg"])
drawplate(conf["homepage"], line, lfil, lab)

while true do
	local eve,_,x,key,sc = ev.pull()
	if eve == "key_down" then
		if key == 200 then ry= ry+1 if ry > 0 then ry = 0 else paradraw() end
		elseif key == 208 then ry= ry-1 if ry > 0 then ry = 0 else paradraw() end
		elseif key == 203 then rx= rx+1 if rx > 0 then rx = 0 else paradraw() end
		elseif key == 205 then rx= rx-1 if rx > 0 then rx = 0 else paradraw() end
		elseif key == 67 then setline() paradraw()
		elseif key == 61 then gohome() paradraw()
		elseif key == 62 then enterurl() paradraw()
		elseif key == 59 then helpmepls() paradraw()
		elseif key == 63 then reload() paradraw()
		elseif key == 65 then offpic() paradraw() end
	elseif eve == "interrupted" then
		if line == true then card.close(3707) end
		rawpage:close()
		tty.clear()
		globalnil()
		if line == true then card.close(3707) end
		print("Thanks for using Memphisto!\n")
		os.exit()
	elseif eve == "scroll" then
		if sc == 1 then ry= ry+1
		elseif sc == -1 then ry= ry-1 end
		if ry > 0 then ry = 0 else paradraw() end
	elseif eve == "touch" then clickop(x, key)
	end
	rawpage:close()
end
