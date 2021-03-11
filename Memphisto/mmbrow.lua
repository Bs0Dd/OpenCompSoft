local _VER_ = "0.02a"

local component = require("component")
local computer = require("computer")
local term = require("term")
local seriz = require("serialization")
local fs = require("filesystem")
local ev = require("event")
local unicode = require("unicode")
local render = require('NyaDrMini')
local sh = require('shell')

local vid = component.gpu

local page, why, conf, servs
local lab = ''
local line = false
local ocifs = {}
local refs = {}
local dwrefs = {}
local padd, lpadd
local picrnd = true
local rx = 0
local ry = 0

local mx, my = vid.getResolution()
local args = sh.parse(...)
	
print("Memphisto NFPL Browser v".._VER_)
print("Developing © 2020-2021 Compys S&N Systems")

render.setGPUProxy(vid)

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
        local res = ''
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
		opn = "/usr/misc/Memphisto/incresp.nfp"
	elseif mode == 2 then
		opn = "/usr/misc/Memphisto/noanswer.nfp"
	elseif mode == 3 then
		opn = "/usr/misc/Memphisto/nilrequ.nfp"
	elseif mode == 4 then
		opn = "/usr/misc/Memphisto/404.nfp"
	elseif mode == 5 then
		opn = "/usr/misc/Memphisto/noicard.nfp"
	end
	local rawpage, why = io.open(opn)
	vid.setForeground(0xFFFFFF)
	if rawpage == nil then
		term.clear()
		print("FATAL ERROR! Can't open system page file: "..why) os.exit() end
	page, why = seriz.unserialize(rawpage:read("*a"))
	if page == nil then
		term.clear()
		print("FATAL ERROR! Can't handle system page file: "..why) os.exit() end
	lab = page['label']
	rx = 0
	ry = 0
	rawpage:close()
end 

local function drawocif(kx, ky, ptox, elm)
	local function lerr(text, kx, ky, elm)
		if elm[1] == 'ilink' then
			render.drawText(kx, ky, 0xFF0000, "IMGLINK: "..text)
			table.insert(refs, {elm[5], kx, kx+unicode.len("LINK: "..text)+3, ky})
		elseif elm[1] == 'idlink' then
			render.drawText(kx, ky, 0xFF0000, "IMDWLINK: "..text)
			table.insert(dwrefs, {elm[5], kx, kx+unicode.len("DWLINK: "..text)+3, ky})
		else
			render.drawText(kx, ky, 0xFF0000, "PICTURE: "..text)
		end
	end
	local function addref(pic, elm, kx, ky)
		if elm[1] == 'ilink' then
			table.insert(refs, {elm[5], kx, kx+pic[1], ky, ky+pic[2]})
		elseif elm[1] == 'idlink' then
			table.insert(dwrefs, {elm[5], kx, kx+pic[1], ky, ky+pic[2]})
		end
	end
	if padd ~= lpadd then ocifs = {} lpadd = padd end
	local parts = split(ptox, "/")
	if parts[1] == ".." then
		local parts2 = split(padd, "/")
		if parts2[1] ~= "file:" then
			parts[1]= parts2[1]..'//'..parts2[2]
			ptox = restore(parts)
		else
			parts2[#parts2] = nil
			table.remove(parts, 1)
			for k, v in pairs(parts) do
				table.insert(parts2, v)
			end
			parts2[1] = 'file:/'
			ptox = restore(parts2)
		end
	end
	if picrnd == false then
		lerr(ptox, kx, ky, elm)
		return
	end
	local parts = split(ptox, "/")
	if parts[1] ~= "file:" then
		if ocifs[ptox] ~= nil then
			render.drawImage(kx, ky, ocifs[ptox])
			addref(ocifs[ptox], elm, kx, ky)
		else
			local card
			if component.list("internet")() == nil then 
				goerr(5)
				return
			else
				card = component.proxy(component.list("internet")())
			end
			local req = card.request(ptox)
			local stt = computer.uptime()
			while not req.finishConnect() do
				if computer.uptime() == stt + 10 or req.finishConnect() == nil then
					goerr(0)
					return
				end
				os.sleep()
			end
			local mess = req.response()
			if mess == nil then
				lerr("Picture not found on server", kx, ky, elm)
				return
			elseif mess == 200 then
				if not fs.isDirectory('/usr/misc/Memphisto/.cached/') then 
					fs.makeDirectory('/usr/misc/Memphisto/.cached/')
				end
				local cache = io.open('/usr/misc/Memphisto/.cached/'..parts[#parts], 'wb')
				local data = ''
				while data ~= nil do
					cache:write(data)
					data = req.read()		
				end
				cache:close()
				local pic = render.loadImage('/usr/misc/Memphisto/.cached/'..parts[#parts])
				fs.remove('/usr/misc/Memphisto/.cached/'..parts[#parts])
				if ocifs[ptox] == nil then ocifs[ptox] = pic end
				render.drawImage(kx, ky, pic)
				addref(pic, elm, kx, ky)
			else
				lerr("Unknown response", kx, ky, elm)
				return
			end
		end
	else
		table.remove(parts, 1)
		ptox = '/'..restore(parts)
		if ocifs[ptox] ~= nil then
			render.drawImage(kx, ky, ocifs[ptox])
			addref(ocifs[ptox], elm, kx, ky)
			return
		end
		local pic, why = render.loadImage(ptox)
		if pic == false then
			if why ~= nil then
				lerr("Can't load picture: "..why, kx, ky, elm)
			else
				lerr("Can't load picture: unknown reason", kx, ky, elm)
			end
			return
		end
		if ocifs[ptox] == nil then ocifs[ptox] = pic end
		render.drawImage(kx, ky, pic)
		addref(pic, elm, kx, ky)
	end
end

local function drawpage(rx, ry, sbk, frscr)
	refs = {}
	dwrefs = {}
	pos = 0
	local page = page
	if frscr then
		page = frscr
	else
		if page.background then render.clear(page.background)
		else render.clear(sbk) end
	end
	while pos ~= #page do
		pos= pos+1
		page[pos][1] = string.lower(page[pos][1])
		if page[pos][1] == 'text' or page[pos][1] == 'link' or page[pos][1] == 'dlink' then
			local x, y, dat, trs, tcol = page[pos][2], page[pos][3]
			if type(page[pos][4]) == "table" then
				for _, block in pairs(page[pos][4]) do
					if block[1] == "DEF" then tcol = (page.background or sbk) else tcol = block[1] end
					if block[2] ~= "DEF" then
						render.drawRectangle(x+rx, y+ry,
							unicode.len(block[3]), 1, block[2], 0x000000, ' ', block[4])
					end
					render.drawText(x+rx, y+ry, tcol, block[3], block[4])
					x = x+unicode.len(block[3])
					dat = page[pos][5]
				end
			else
				if type(page[pos][#page[pos]]) == "string" then trs = nil else trs = page[pos][#page[pos]] end
				if page[pos][4] == "DEF" then tcol = (page.background or sbk) else tcol = page[pos][4] end
				if page[pos][5] ~= "DEF" then
						render.drawRectangle(x+rx, y+ry,
							unicode.len(page[pos][6]), 1, page[pos][5], 0x000000, ' ', trs)
				end
				render.drawText(x+rx, y+ry, tcol, page[pos][6], trs)
				x = x+unicode.len(page[pos][6])
				dat = page[pos][7]
			end
			if page[pos][1] == 'link' then
				table.insert(refs, {dat, page[pos][2]+rx, x+rx, y+ry})
			elseif page[pos][1] == 'dlink' then
				table.insert(dwrefs, {dat, page[pos][2]+rx, x+rx, y+ry})
			end
		elseif page[pos][1] == 'image' or page[pos][1] == 'ilink' or page[pos][1] == 'idlink' then
			drawocif(page[pos][2]+rx, page[pos][3]+ry, page[pos][4], page[pos])
		elseif page[pos][1] == 'rectangle' or page[pos][1] == 'line' or page[pos][1] == 'ellipse' then
			local lry, crx, cry, drawer, fcol, bcol = ry, page[pos][4], page[pos][5]
			if page[pos][1] == 'rectangle' then 
				if page[pos][8] then drawer = render.drawSemiPixelRectangle lry = lry*2
				else drawer = render.drawRectangle end
			elseif page[pos][1] == 'line' then
				if page[pos][8] then drawer = render.drawSemiPixelLine lry = lry*2
				else drawer = render.drawLine end
				crx, cry = page[pos][4]+rx, page[pos][5]+lry
			elseif page[pos][1] == 'ellipse' then
				if page[pos][8] then drawer = render.drawSemiPixelEllipse lry = lry*2
				else drawer = render.drawEllipse end
			end
			if page[pos][6] == "DEF" then fcol = (page.background or sbk) else fcol = page[pos][6] end
			if page[pos][7] == "DEF" then bcol = (page.background or sbk) else bcol = page[pos][7] end			
			drawer(page[pos][2]+rx, page[pos][3]+lry, crx, cry, bcol, fcol,
				unicode.sub(page[pos][9] or ' ', 1, 1), page[pos][10])
		elseif page[pos][1] == 'curve' then
			local dots, fcol, bcol = {}
			for _, v in pairs(page[pos][2]) do
				v = {x = v[1]+rx, y = v[2]+(ry*2)}
				table.insert(dots, v)
			end
			if page[pos][3] == "DEF" then fcol = (page.background or sbk) else fcol = page[pos][3] end
			if page[pos][4] == "DEF" then bcol = (page.background or sbk) else bcol = page[pos][4] end	
			render.drawSemiPixelCurve(dots, fcol, bcol)
		elseif page[pos][1] == 'border' then
			if type(page[pos][#page[pos]]) == "string" then trs = nil else trs = page[pos][#page[pos]] end
			local bsym
			if page[pos][7] == 'dash' then bsym = '-'
			elseif page[pos][7] == 'equal' then bsym = '='
			elseif page[pos][7] == 'pseudo' then bsym = '─'
			elseif page[pos][7] == 'dpseudo' then bsym = '═'
			else bsym = page[pos][7] end
			local brd = unicode.sub(string.rep(bsym, page[pos][4]),0,page[pos][4])
			if page[pos][6] ~= "DEF" then
				render.drawRectangle(page[pos][2]+rx, page[pos][3]+ry,
					unicode.len(brd), 1, page[pos][6], trs, ' ')
			end
			render.drawText(page[pos][2]+rx, page[pos][3]+ry, page[pos][5], brd, trs)
		elseif page[pos][1] == 'frame' then
			local tlen, fcol, bcol, bsym = 0
			if page[pos][5] == "DEF" then fcol = (page.background or sbk) else fcol = page[pos][5] end
			if type(page[pos][7]) == 'table' then bsym = page[pos][7]
			elseif page[pos][7] == 'dash' then bsym = {'/', '-', '\\', '\\', '|', '/'}
			elseif page[pos][7] == 'equal' then bsym = {'/', '=', '\\', '\\', '|', '/'}
			elseif page[pos][7] == 'pseudo' then bsym = {'┌', '─', '┐', '└', '│', '┘'}
			elseif page[pos][7] == 'dpseudo' then bsym = {'╔', '═', '╗', '╚', '║', '╝'} end
			for _, row in pairs(page[pos][8]) do
				local rowlen = 0
				if type(row[1]) == 'table' then
					for _, elem in pairs(row) do
						rowlen = rowlen + unicode.len(elem[3])
					end
				else
					rowlen = rowlen + unicode.len(row[3])
				end
				if rowlen > tlen then tlen = rowlen end
			end
			if tlen < page[pos][4] then tlen = page[pos][4] end
			local fp = bsym[1]..unicode.sub(string.rep(bsym[2], tlen),0,tlen)..bsym[3]
			local lp = bsym[4]..unicode.sub(string.rep(bsym[2], tlen),0,tlen)..bsym[6]
			if page[pos][6] ~= "DEF" then
				if bsym[7] then
				render.drawRectangle(page[pos][2]+rx+1, page[pos][3]+ry+1,
					tlen, #page[pos][8], page[pos][6], 0x000000, ' ', page[pos][9])
				else
				render.drawRectangle(page[pos][2]+rx, page[pos][3]+ry,
					tlen+2, #page[pos][8]+2, page[pos][6], 0x000000, ' ', page[pos][9])
				end
			end
			render.drawText(page[pos][2]+rx, page[pos][3]+ry, fcol, fp, page[pos][9])
			render.drawText(page[pos][2]+rx, page[pos][3]+ry+#page[pos][8]+1, fcol, lp, page[pos][9])
			local rowlen, x, y = 0, page[pos][2]+1, page[pos][3]+1
			for _, row in pairs(page[pos][8]) do
				render.drawText(x+rx-1, y+ry, fcol, bsym[5], page[pos][9])
				if type(row[1]) == 'table' then
					for _, block in pairs(row) do
						if block[1] == "DEF" then tcol = (page.background or sbk) else tcol = block[1] end
						if block[2] ~= "DEF" then
							render.drawRectangle(x+rx, y+ry,
								unicode.len(block[3]), 1, block[2], 0x000000, ' ', block[4])
						end
						render.drawText(x+rx, y+ry, tcol, block[3], block[4])
						x = x+unicode.len(block[3])
					end
				else
					if type(row[#row]) == "string" then trs = nil else trs = row[#row] end
					if row[1] == "DEF" then tcol = (page.background or sbk) else tcol = row[1] end
					if row[2] ~= "DEF" then
							render.drawRectangle(x+rx, y+ry,
								unicode.len(row[3]), 1, row[2], 0x000000, ' ', trs)
					end
					render.drawText(x+rx, y+ry, tcol, row[3], trs)
					x = x+unicode.len(page[pos][6])
				end
				render.drawText(page[pos][2]+tlen+rx+1, y+ry, fcol, bsym[5], page[pos][9])
				y = y+1
				x = page[pos][2]+1
			end
		elseif page[pos][1] == 'semipixel' then
			local fcol
			if page[pos][4] == "DEF" then fcol = (page.background or sbk) else fcol = page[pos][4] end
			render.semiPixelSet(page[pos][2]+rx, page[pos][3]+ry, fcol)
		end
	end
	if conf.showMem then
		local free = computer.freeMemory()
		render.drawRectangle(mx-#tostring(free), 1, #tostring(free), 1, 0xFFFFFF, 0x000000, ' ')
		render.drawText(mx-#tostring(free), 1, 0x000000, free)
	end
end

local function drawplate(pnam, ofon, lab)
  	render.drawLine(1,my,mx,my, 0xFFFFFF, 0x000000, ' ')
  	render.drawText(2, my, 0x000000, "Memphisto NFPL Browser v".._VER_)
  	tform = ''
  	if lab ~= nil and lab ~= '' then tform = ' - '..lab end
	local text = pnam..tform
	if unicode.len(text) > mx-51 then text = '..'..unicode.sub(text,-(mx-53)) end
  	render.drawText(36, my, 0x000000, "Page: "..text)
  	if ofon == true then
  		render.drawRectangle(mx-7, my, 7, 1, 0x00FF00)
  		render.drawText(mx-7, my, 0x000000, "ON-LINE")
  	else
  		render.drawRectangle(mx-8, my, 8, 1, 0xFF0000)
  		render.drawText(mx-8, my, 0x000000, "OFF-LINE")
  	end
	render.update()
end

local function waitansw(request)
	local stt = computer.uptime()
		while not request.finishConnect() do
			if computer.uptime() == stt + 10 then
				goerr(2)
				return false
			elseif request.finishConnect() == nil then
				if table.pack(request.finishConnect())[2]:sub(0,12) == 'unknown host' then
					goerr(3)
				else
					goerr(4)
				end
				return false
			end	
			os.sleep()
		end
	return true
end

local function openpage(inp)
	if inp == "" then return end
	local parts = split(inp, "/")
	if inp == '..' then
		local parts2 = split(padd, "/")
		inp = parts2[1]..'//'..parts2[2]
	elseif parts[1] == ".." then
		local parts2 = split(padd, "/")
		if parts2[1] ~= "file:" then
			parts[1]= parts2[1]..'//'..parts2[2]
			inp = restore(parts)
		else
			parts2[#parts2] = nil
			table.remove(parts, 1)
			for k, v in pairs(parts) do
				table.insert(parts2, v)
			end
			parts2[1] = 'file:/'
			inp = restore(parts2)
		end
	end
	if parts[#parts]:lower():sub(-4) ~= '.nfp' then
		if inp:sub(-1) == '/' then
			inp = inp..'index.nfp'
		else
			inp = inp..'/index.nfp'
		end
	end
	rx = 0
	ry = 0
	local parts = split(inp, "/")
	drawplate(inp, line, 'Loading...')
	if parts[1] ~= "file:" then
		local card
		padd = inp
		if component.list("internet")() == nil then 
			goerr(5)
			return
		else
			card = component.proxy(component.list("internet")())
			line = true
		end
		drawplate(padd, line, 'Loading...')
		local htyp = string.gmatch(inp, "([^//]+)")():lower() 
		if not (htyp == "http:" or htyp == "https:") then
			inp = "http://"..inp
			padd = inp
			drawplate(padd, line, 'Loading...')
		end
		req = card.request(padd)
		if not waitansw(req) then return end
		while true do
			if req.response() == 301 then
				local _, _, t = req.response()
				padd = t.Location[1]
				drawplate(padd, line, 'Loading...')
				req = card.request(padd)
			else break end
		end
		if not waitansw(req) then return end
		mess = req.response()
		if mess == nil then
			goerr(4)
			return
		elseif mess == 200 then
			rpage = ''
			local data = ''
			while data ~= nil do
				rpage = rpage..data
				data = req.read()
			end
			page = seriz.unserialize(rpage)
			if page == nil then
				goerr(0)
				return
			end
		else
			goerr(1)
		end
		if page['label'] ~= nil then lab = page['label'] else lab = '' end
		return 
	else
		line = false
		table.remove(parts, 1)
		padd = inp
		inp = '/'..restore(parts)
		local rawpage = io.open(inp)
		if rawpage == nil then
			goerr(4)
			return
		end
		page = seriz.unserialize(rawpage:read("*a"))
		if page == nil then
			goerr(0)
			return
		end
		if page['label'] ~= nil then lab = page['label'] else lab = '' end
		rawpage:close()
		return
	end
end

local function enterurl()
	render.drawLine(42, my, mx-10, my, 0x5A5A5A, 0x000000, ' ')
	render.update()
	local inp = padd
	local see
	while true do
		if unicode.len(inp) > mx - 53 then seen ='..'.. unicode.sub(inp,-(mx-55)) else seen = inp end
		vid.set(43, my, seen)
		term.setCursor(43+unicode.len(seen), my)
		eve,_,key = term.pull()
		if eve == "key_down" then
			if key == 8 then
    			inp = unicode.sub(inp,1,-2)
				vid.set(unicode.len(seen)+42, my, ' ')
  			elseif key == 13 then
    			openpage(inp)
    			return
    		elseif key == 0 or key == 9 or key == 127 then
  			else
    			inp = inp..unicode.char(key)
    			end
		elseif eve == "interrupted" then return
		elseif eve == "clipboard" then 
			inp = inp..key
		end
	end
end

local function gohome()
	rx = 0
	ry = 0
	padd = conf.homepage
	openpage(padd)
end

local function helpmepls()
	rx = 0
	ry = 0
	padd = 'file://usr/misc/Memphisto/help.nfp'
	openpage(padd)
end

local function reload()
	rx = 0
	ry = 0
	ocifs = {}
	openpage(padd)
end

local function paradraw()
	drawpage(rx, ry, conf.background)
	drawplate(padd, line, lab)
end

local function download(dwp)
	local _, mess, mess2, key
	term.clear()
	render.clear(conf.background)
	render.update()
	drawplate(padd, line, lab)
	local parts = split(dwp, "/")
	if parts[1] ~= "file:" then
		if parts[1] == ".." then
			local parts2 = split(padd, "/")
			parts[1]= parts2[1]..'//'..parts2[2]
			local dwp = restore(parts)
		end
		print('Do you want to download file: '..parts[#parts]..'? Y/N')
		while true do
			_, _, _, key = ev.pull("key_up")
			if key == 21 then break
			elseif key == 49 then paradraw() return end
		end
		local card
		if component.list("internet")() == nil then 
			goerr(5)
			return
		else
			card = component.proxy(component.list("internet")())
		end
		local req = card.request(padd)
		local stt = computer.uptime()
		while not req.finishConnect() do
			if computer.uptime() == stt + 10 or req.finishConnect() == nil then
				goerr(0)
				return
			end
			os.sleep()
		end
		mess = req.response()
		print("Downloading file...")
		if mess == nil then
			print("ERROR: File not found")
			prac()
			return
		elseif mess == 200 then
			local savto = fs.concat(conf.downloadDir, parts[#parts])
			local sav = io.open(savto, 'wb')
			local data = ''
			while data ~= nil do
				sav:write(data)
				data = req.read()		
			end
			sav:close()
			print("File downloaded!")
			prac()
			paradraw()
		else
			print("ERROR: Unknown response")
			prac()
			return 
			end
	else
		table.remove(parts, 1)
		dwp = '/'..restore(parts)
		local fil = io.open(dwp, 'rb')
		print('Do you want to download file: '..parts[#parts]..'? Y/N')
		while true do
			_, _, _, key = ev.pull("key_up")
			if key == 21 then break
			elseif key == 49 then return end
		end
		print("Downloading file...")
		local savto = fs.concat(conf.downloadDir, parts[#parts])
		local sav = io.open(savto, 'wb')
		local rded = fil:read()
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
			local sec = ref[5] or ref[4]+1
			if ref[4] <= ky and ky < sec and ref[2] <= kx and kx < ref[3] then
				openpage(ref[1])
				rx=0
				ry=0
				drawpage(rx, ry, conf.background)
				drawplate(padd, line, lab)
				return
			end
		end
		for _, dref in pairs(dwrefs) do
			local sec = dref[5] or dref[4]+1
			if dref[4] <= ky and ky < sec and dref[2] <= kx and kx < dref[3] then
				download(dref[1])
				return
			end
		end
	end
end

local function offpic()
	if picrnd == true then picrnd = false
	else picrnd = true end
end

render.clear(0)
render.update()
local rawconf, why = io.open("/etc/mmbrow.cfg")
if rawconf == nil then
	print("FATAL ERROR! Can't open config file: "..why) return end
conf, why = seriz.unserialize(rawconf:read("*a"))
rawconf:close()
if conf == nil then
	print("FATAL ERROR! Can't handle config file: "..why) return end
padd = args[1] or conf.homepage
openpage(padd)
drawpage(rx, ry, conf.background)
drawplate(padd, line, lab)

while true do
	local eve,_,x,key,sc = ev.pull()
	if eve == "key_down" then
		if key == 200 then ry= ry+1 if ry > 0 then ry = 0 else paradraw() end
		elseif key == 208 then ry= ry-1 if ry > 0 then ry = 0 else paradraw() end
		elseif key == 203 then rx= rx+1 if rx > 0 then rx = 0 else paradraw() end
		elseif key == 205 then rx= rx-1 if rx > 0 then rx = 0 else paradraw() end
		elseif key == 61 then gohome() paradraw()
		elseif key == 62 then enterurl() paradraw()
		elseif key == 59 then helpmepls() paradraw()
		elseif key == 63 then reload() paradraw()
		elseif key == 65 then offpic() paradraw() end
	elseif eve == "interrupted" then
		vid.setBackground(0x000000)
		vid.setForeground(0xFFFFFF)
		term.clear()
		print("Thanks for using Memphisto!\n")
		os.exit()
	elseif eve == "scroll" then
		if sc == 1 then ry= ry+1
		elseif sc == -1 then ry= ry-1 end
		if ry > 0 then ry = 0 else paradraw() end
	elseif eve == "touch" then clickop(x, key)
	end
end
