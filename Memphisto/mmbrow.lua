local _VER_ = "0.03a"

local component = require("component")
local computer = require("computer")

local sr = require("serialization")
local fs = require("filesystem")
local ev = require("event")
local unicode = require("unicode")
local render = require('NyaDrMini')
local sh = require('shell')
local term = require('term')

local gpu = component.gpu
local ser = sr.serialize
local unser = sr.unserialize
local pull = ev.pull
local ulen = unicode.len
local usub = unicode.sub


local pagaddr, pagecont
local hyper, hyperdw
local hypjour, hypjpos = {}, 1
local config
local pagposX, pagposY = 0, 0
local piccache = {}
local picrendr = true
local intcard
local isonline = false

local resX, resY = 160, 50
local args = sh.parse(...)


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


local function transfPath(path, addindex)
    local parts = split(path, "/")
    if path == '..' then
        local parts2 = split(pagaddr, "/")
        path = parts2[1]..'//'..parts2[2]
    elseif parts[1] == ".." then
        local parts2 = split(pagaddr, "/")
        if parts2[1] ~= "file:" then
            parts[1]= parts2[1]..'//'..parts2[2]
            path = restore(parts)
        else
            parts2[#parts2] = nil
            table.remove(parts, 1)
            for k, v in pairs(parts) do
                table.insert(parts2, v)
            end
            parts2[1] = 'file:/'
            path = restore(parts2)
        end
    end
    
    local htyp = string.gmatch(path, "([^//]+)")():lower() 
    if not (htyp == "http:" or htyp == "https:" or htyp == "file:") then
        path = "http://"..path
    end
    
    if addindex then
        parts = split(path, "/")
        if #parts <= 2 then
            if path:sub(-1) == '/' then
                path = path..'index.nfp'
            else
                path = path..'/index.nfp'
            end
        end
    end
    
    return path
end


local function picDraw(elem)
    local kx, ky = elem[2]+pagposX, elem[3]+pagposY
    local path = transfPath(elem[4], false)
    
    local function lerr(text, elem)
        if elem[1] == 'ilink' and type(elem[5]) == "string" then
            render.drawText(kx, ky, 0xFF0000, "IMGLINK: "..text)
            table.insert(hyper, {elem[5], kx, kx+ulen("IMGLINK: "..text)+3, ky})
        elseif elem[1] == 'idlink' and type(elem[5]) == "string" then
            render.drawText(kx, ky, 0xFF0000, "IMDWLINK: "..text)
            table.insert(hyperdw, {elem[5], kx, kx+ulen("IMDWLINK: "..text)+3, ky})
        else
            render.drawText(kx, ky, 0xFF0000, "PICTURE: "..text)
        end
    end
    
    local function addref(pic, elem)
        if elem[1] == 'ilink' and type(elem[5]) == "string" then
            table.insert(hyper, {elem[5], kx, kx+pic[1], ky, ky+pic[2]})
        elseif elem[1] == 'idlink' and type(elem[5]) == "string" then
            table.insert(hyperdw, {elem[5], kx, kx+pic[1], ky, ky+pic[2]})
        end
    end
    
    if not picrendr then
        lerr(path, elem)
        return
    end
    local parts = split(path, "/")
    if parts[1] ~= "file:" then
        if piccache[path] ~= nil then
            render.drawImage(kx, ky, piccache[path])
            addref(piccache[path], elem, kx, ky)
        else
            if component.isAvailable("internet") then
                intcard = component.internet
            else
                lerr("Can't load picture: no internet card", elem)
                return
            end
            local req = intcard.request(path)
            if not req then
                lerr("Can't load picture: nil request", elem)
                return
            end
            local stt = computer.uptime()
            while not req.finishConnect() do
                if computer.uptime() == stt + 10 then
                    lerr("Can't load picture: timeout", elem)
                    return
                elseif req.finishConnect() == nil then
                    local err = table.pack(req.finishConnect())[2]
                    if err:sub(0,12) == 'unknown host' then
                        lerr("Can't load picture: unknown host", elem)
                    elseif err == pagaddr then
                        lerr("Picture not found on the server", elem)
                    else
                        lerr(err, elem)
                    end
                    return
                end
                os.sleep()
            end
            
            local code, msg = req.response()
            if code ~= 200 then
                lerr("Server returned HTTP response code: "..math.floor(code)..", message: "..msg, elem)
                return
            end
            
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
            if piccache[path] == nil then piccache[path] = pic end
            render.drawImage(kx, ky, pic)
            addref(pic, elem)
        end
    else
        table.remove(parts, 1)
        path = '/'..restore(parts)
        if piccache[path] ~= nil then
            render.drawImage(kx, ky, piccache[path])
            addref(piccache[path], elem)
            return
        end
        local pic, why = render.loadImage(path)
        if pic == false then
            if why ~= nil then
                lerr("Can't load picture: "..why, elem)
            else
                lerr("Can't load picture: unknown reason", elem)
            end
            return
        end
        if piccache[path] == nil then piccache[path] = pic end
        render.drawImage(kx, ky, pic)
        addref(pic, elem)
    end
end


local function drawStatBar(pagaddr, online, label)
    render.drawLine(1, resY, resX, resY, 0xFFFFFF, 0x000000, ' ')
    render.drawText(2, resY, 0x000000, "Memphisto v".._VER_)
    render.drawLine(21, resY, 32, resY, 0xC3C3C3, 0x000000, ' ')
    render.drawText(22, resY, 0x000000, "H     *")
    render.drawText(25, resY, hypjpos ~= 1 and 0x000000 or 0xA5A5A5, "←")
    render.drawText(31, resY, hypjpos ~= #hypjour and 0x000000 or 0xA5A5A5, "→")
    local text = pagaddr..(label ~= nil and label ~= '' and ' - '..label or '')
    if ulen(text) > resX-51 then text = '..'..usub(text,-(resX-53)) end
    render.drawText(36, resY, 0x000000, "Page: "..text)
    if online then
        render.drawRectangle(resX-7, resY, 7, 1, 0x00FF00)
        render.drawText(resX-7, resY, 0x000000, "ON-LINE")
    else
        render.drawRectangle(resX-8, resY, 8, 1, 0xFF0000)
        render.drawText(resX-8, resY, 0x000000, "OFF-LINE")
    end
    render.update()
end


local function drawPage()
    local function isValidElem(elem, desc)
        if #desc+1 > #elem then return false end
        local i = 1
        while i <= #desc do
            if type(desc[i]) == "table" then
                local flag = false
                for _, v in pairs(desc[i]) do
                    if type(elem[i+1]) == v then flag = true break end
                end
                if not flag then return false end
            else
                if type(elem[i+1]) ~= desc[i] then return false end
            end
            i = i + 1
        end
        return true
    end
    
    hyper = {}
    hyperdw = {}
    render.clear(pagecont.background or config.background)
    for num, elem in ipairs(pagecont) do
        if elem[1] == 'text' or elem[1] == 'link' or elem[1] == 'dlink' then
            if isValidElem(elem, {'number', 'number', {'number', 'string'},
                                  {'number', 'string'}, 'string'}) or 
                    isValidElem(elem, {'number', 'number', 'table'}) then
                local eX, eY, color, htext = elem[2], elem[3]
                if type(elem[4]) == "table" then
                    for _, block in pairs(elem[4]) do
                        color = block[1] ~= "DEF" and block[1] or (pagecont.background or config.background)
                        if block[2] ~= "DEF" then
                            render.drawRectangle(eX+pagposX, eY+pagposY,
                                ulen(block[3]), 1, block[2], 0x000000, ' ', block[4])
                        end
                        render.drawText(eX+pagposX, eY+pagposY, color, block[3], block[4])
                        eX = eX+ulen(block[3])
                        htext = elem[5]
                    end
                else
                    if type(elem[#elem]) == "string" then trs = nil else trs = elem[#elem] end
                    color = elem[4] ~= "DEF" and elem[4] or (pagecont.background or config.background)
                    if elem[5] ~= "DEF" then
                        render.drawRectangle(eX+pagposX, eY+pagposY,
                            ulen(elem[6]), 1, elem[5], 0x000000, ' ', trs)
                    end
                    render.drawText(eX+pagposX, eY+pagposY, color, elem[6], trs)
                    eX = eX+ulen(elem[6])
                    htext = elem[7]
                end
                if elem[1] == 'link' and htext then
                    table.insert(hyper, {htext, elem[2]+pagposX, eX+pagposX, eY+pagposY})
                elseif elem[1] == 'dlink' and htext then
                    table.insert(hyperdw, {htext, elem[2]+pagposX, eX+pagposX, eY+pagposY})
                end
            end
        elseif elem[1] == 'image' or elem[1] == 'ilink' or elem[1] == 'idlink' then
           if isValidElem(elem, {'number', 'number', 'string'}) then
               picDraw(elem)
           end
        elseif elem[1] == 'rectangle' or elem[1] == 'line' or elem[1] == 'ellipse' then
            if isValidElem(elem, {'number', 'number', 'number', 'number',
                                  {'number', 'string'}, {'number', 'string'}}) then
                local lry, crx, cry, drawer, fcol, bcol = pagposY, elem[4], elem[5]
                if elem[1] == 'rectangle' then 
                    if elem[8] then drawer = render.drawSemiPixelRectangle lry = lry*2
                    else drawer = render.drawRectangle end
                elseif elem[1] == 'line' then
                    if elem[8] then drawer = render.drawSemiPixelLine lry = lry*2
                    else drawer = render.drawLine end
                    crx, cry = elem[4]+pagposX, elem[5]+lry
                elseif elem[1] == 'ellipse' then
                    if elem[8] then drawer = render.drawSemiPixelEllipse lry = lry*2
                    else drawer = render.drawEllipse end
                end
                fcol = elem[6] == "DEF" and (pagecont.background or config.background) or elem[6]
                bcol = elem[7] == "DEF" and (pagecont.background or config.background) or elem[7]
                drawer(elem[2]+pagposX, elem[3]+lry, crx, cry, bcol, fcol,
                    usub(elem[9] or ' ', 1, 1), elem[10])
            end
        elseif elem[1] == 'curve' then
            if isValidElem(elem, {'table', {'number', 'string'}, 'number'}) then
                local dots, fcol, bcol = {}
                for _, v in pairs(elem[2]) do
                    v = {x = v[1]+pagposX, y = v[2]+(pagposY*2)}
                    table.insert(dots, v)
                end
                fcol = elem[3] == "DEF" and (pagecont.background or config.background) or elem[3]
                bcol = elem[4] == "DEF" and (pagecont.background or config.background) or elem[4]
                render.drawSemiPixelCurve(dots, fcol, bcol)
            end
        elseif elem[1] == 'border' then
            if isValidElem(elem, {'number', 'number', 'number', {'number', 'string'},
                                  {'number', 'string'}, 'string'}) then
                local trs = type(elem[#elem]) ~= "string" and elem[#elem] or nil
                local bsym
                if elem[7] == 'dash' then bsym = '-'
                elseif elem[7] == 'equal' then bsym = '='
                elseif elem[7] == 'pseudo' then bsym = '─'
                elseif elem[7] == 'dpseudo' then bsym = '═'
                else bsym = elem[7] end
                local brd = usub(string.rep(bsym, elem[4]),0,elem[4])
                if elem[6] ~= "DEF" then
                    render.drawRectangle(elem[2]+pagposX, elem[3]+pagposX,
                        ulen(brd), 1, elem[6], trs, ' ')
                end
                render.drawText(elem[2]+pagposX, elem[3]+pagposY, elem[5], brd, trs)
            end
        elseif elem[1] == 'frame' then
            if isValidElem(elem, {'number', 'number', 'number', {'number', 'string'}, 
                                  {'number', 'string'}, {'string', 'table'}, 'table'}) then
                local tlen, fcol, bcol, bsym = 0
                fcol = elem[5] == "DEF" and (pagecont.background or config.background) or elem[5]
                if type(elem[7]) == 'table' then bsym = elem[7]
                elseif elem[7] == 'dash' then bsym = {'/', '-', '\\', '\\', '|', '/'}
                elseif elem[7] == 'equal' then bsym = {'/', '=', '\\', '\\', '|', '/'}
                elseif elem[7] == 'pseudo' then bsym = {'┌', '─', '┐', '└', '│', '┘'}
                elseif elem[7] == 'dpseudo' then bsym = {'╔', '═', '╗', '╚', '║', '╝'} end
                for _, row in pairs(elem[8]) do
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
                if tlen < elem[4] then tlen = elem[4] end
                local fp = bsym[1]..usub(string.rep(bsym[2], tlen),0,tlen)..bsym[3]
                local lp = bsym[4]..usub(string.rep(bsym[2], tlen),0,tlen)..bsym[6]
                if elem[6] ~= "DEF" then
                    if bsym[7] then
                    render.drawRectangle(elem[2]+pagposX+1, elem[3]+pagposY+1,
                        tlen, #elem[8], elem[6], 0x000000, ' ', elem[9])
                    else
                    render.drawRectangle(elem[2]+pagposX, elem[3]+pagposY,
                        tlen+2, #elem[8]+2, elem[6], 0x000000, ' ', elem[9])
                    end
                end
                render.drawText(elem[2]+pagposX, elem[3]+pagposY, fcol, fp, elem[9])
                render.drawText(elem[2]+pagposX, elem[3]+pagposY+#elem[8]+1, fcol, lp, elem[9])
                local rowlen, x, y = 0, elem[2]+1, elem[3]+1
                for _, row in pairs(elem[8]) do
                    render.drawText(x+pagposX-1, y+pagposY, fcol, bsym[5], elem[9])
                    if type(row[1]) == 'table' then
                        for _, block in pairs(row) do
                            tcol = block[1] == "DEF" and (pagecont.background or config.background) or block[1]
                            if block[2] ~= "DEF" then
                                render.drawRectangle(x+pagposX, y+pagposY,
                                    ulen(block[3]), 1, block[2], 0x000000, ' ', block[4])
                            end
                            render.drawText(x+pagposX, y+pagposY, tcol, block[3], block[4])
                            x = x+ulen(block[3])
                        end
                    else
                        if type(row[#row]) == "string" then trs = nil else trs = row[#row] end
                        tcol = row[1] == "DEF" and (pagecont.background or config.background) or row[1]
                        if row[2] ~= "DEF" then
                                render.drawRectangle(x+pagposX, y+pagposY,
                                    ulen(row[3]), 1, row[2], 0x000000, ' ', trs)
                        end
                        render.drawText(x+pagposX, y+pagposY, tcol, row[3], trs)
                        x = x+ulen(elem[6])
                    end
                    render.drawText(elem[2]+tlen+pagposX+1, y+pagposY, fcol, bsym[5], elem[9])
                    y = y+1
                    x = elem[2]+1
                end
            end
        elseif elem[1] == 'semipixel' then
            if isValidElem(elem, {'number', 'number', 'number'}) then
                local fcol = elem[4] == "DEF" and (pagecont.background or sbk) or elem[4]
                render.semiPixelSet(elem[2]+pagposX, elem[3]+pagposY, fcol)
            end
        end
    end
    
    if config.showRam then
        local free = "Free RAM: "..computer.freeMemory()
        render.drawRectangle(resX-#free, 1, #free, 1, 0xFFFFFF, 0x000000, ' ')
        render.drawText(resX-#free, 1, 0x000000, free)
    end
    drawStatBar(pagaddr, isonline, pagecont.label)
end


local function loadPage(path, nojour)
    local function initErr(mode, addit)
        local errlbl, errtxt
        if mode == 0 then
            errlbl = "Incorrect page!"
            errtxt = "handle this page, please check if code is correct."
        elseif mode == 1 then
            errlbl = "Received error code!"
            errtxt = "load page, because server returned error code, please try again later."
        elseif mode == 2 then
            errlbl = "No answer from server!"
            errtxt = "connect to server, please check if address is correct or server is working."
        elseif mode == 3 then
            errlbl = "Can't open Internet request!"
            errtxt = "open HTTP(S) request, please check if Internet is connected or site is exists."
        elseif mode == 4 then
            errlbl = "404 - Page not found!"
            errtxt = "get this page, please check if address is correct."
        elseif mode == 5 then
            errlbl = "No Internet card!"
            errtxt = "find Internet card. It's needed to open the remote page."
        end
    
        pagecont = { label = errlbl,
                    { 'text', 4, 2, 0xFF0000, "DEF", "[OOPS! "..errlbl.."]"},
                    { 'image', 3, 4, "file://usr/misc/Memphisto/failed.pic"},
                    { 'text', 1, 11, 0xFFFFFF, "DEF", "Sorry, but I can't "..errtxt},
                    { 'border', 1, addit and 14 or 13, 90, 0x00FFFF, "DEF", 'dpseudo'},
                    { 'text', 1, addit and 15 or 14, 0x00FFFF, "DEF", "Browser developing © 2020-2022 Compys S&N Systems"}
                }
        if addit then
            table.insert(pagecont, 4, { 'text', 1, 12, 0xFF0000, "DEF", addit})
        end
        drawPage()
    end
    
    local function waitAnswer(request)
        local stt = computer.uptime()
            while not request.finishConnect() do
                if computer.uptime() == stt + 10 then
                    initErr(2)
                    return false
                elseif request.finishConnect() == nil then
                    local err = table.pack(request.finishConnect())[2]
                    if err:sub(0,12) == 'unknown host' then
                        initErr(3)
                    elseif err == pagaddr then
                        initErr(4)
                    else
                        initErr(1, err)
                    end
                    return false
                end	
                os.sleep()
            end
        return true
    end
    
    
    if path == "" then return end
    piccache = {}
    pagposX, pagposY = 0, 0
    
    path = transfPath(path, true)
    
    if not nojour and path ~= pagaddr then
        if #hypjour ~= hypjpos then
            for i = #hypjour, hypjpos + 1, -1 do
                hypjour[i] = nil
            end
        end
        table.insert(hypjour, path)
        hypjpos = #hypjour
    end
    
    pagaddr = path
    local parts = split(pagaddr, "/")
    drawStatBar(pagaddr, isonline, 'Loading...')
    
    if parts[#parts]:sub(-4):lower() == '.pic' then
            isonline = (component.isAvailable("internet") and parts[1] ~= "file:") and true or false
            pagecont = {label = 'OCIF Picture View: '..parts[#parts],
                         {'text', 3, 2, 0xFFFFFF, "DEF", 'OCIF Picture View: '..parts[#parts]},
                         {'border', 2, 3, 65, 0x5A5A5A, "DEF", 'pseudo'},
                         {'idlink', 3, 5, path, path},
                        }
            drawStatBar(pagaddr, isonline, 'Loading...')
    elseif parts[1] ~= "file:" then
        if component.isAvailable("internet") then
            intcard = component.internet
            isonline = true
        else
            isonline = false
            initErr(5)
            return
        end
        drawStatBar(pagaddr, isonline, 'Loading...')
        local req = intcard.request(pagaddr)
        if not req then
            initErr(3)
            return
        end
        local moved = false
        if not waitAnswer(req) then return end
        while true do
            if req.response() == 301 then
                moved = true
                local _, _, t = req.response()
                pagaddr = t.Location[1]
                drawStatBar(pagaddr, isonline, 'Loading...')
                req = intcard.request(pagaddr)
            else break end
        end
        if moved and not waitAnswer(req) then return end
        
        local code, msg = req.response()
        if code ~= 200 then
            initErr(1, "Server returned HTTP response code: "..math.floor(code)..", message: "..msg)
            return
        end
        
        local data, rpage = '', ''
        while data ~= nil do
            rpage = rpage..data
            data = req.read()
        end
        
        local why
        pagecont, why = unser(rpage)
        if pagecont == nil then
            initErr(0, "Unserialization error: "..why)
            return
        end
    else
        isonline = false
        table.remove(parts, 1)
        path = '/'..restore(parts)
        local rawpage = io.open(path)
        if rawpage == nil then
            initErr(4)
            return
        end
        pagecont = unser(rawpage:read("*a"))
        if pagecont == nil then
            initErr(0)
            return
        end
        rawpage:close()
    end
    drawPage()
end


local function scrollPage(axisy, direction)
    local axis = axisy and pagposY+direction or pagposX+direction
    if axis > 0 then axis = 0 return end
    if axisy then pagposY = axis
    else pagposX = axis end
    drawPage()
end


local function enterUrl()
    render.drawLine(42, resY, resX-10, resY, 0x5A5A5A, 0x000000, ' ')
    render.update()
    local inp = pagaddr
    local see
    while true do
        if ulen(inp) > resX - 53 then seen ='..'.. usub(inp,-(resX-55)) else seen = inp end
        gpu.set(43, resY, seen)
        term.setCursor(43+unicode.len(seen), resY)
        eve,_,sym,key = term.pull()
        if eve == "key_down" then
            if sym == 8 then
                inp = unicode.sub(inp,1,-2)
                gpu.set(unicode.len(seen)+42, resY, ' ')
            elseif sym == 13 then
                loadPage(inp)
                return
            elseif sym == 0 or sym == 9 or sym == 127 then
            else
                inp = inp..unicode.char(sym)
            end
        elseif eve == "interrupted" then
            drawPage()
            return
        elseif eve == "clipboard" then 
            inp = inp..sym
        end
    end
end


local function downloadFile(dwp)
    local function anyKey(line)
        render.drawText(1, line, 0xFFFFFF, "Press any key to continue.")
        render.update()
        pull("key_down")
        drawPage()
    end
    
    local line = 1
    render.clear(config.background)
    drawStatBar(pagaddr, isonline, pagecont.label)
    
    dwp = transfPath(dwp, false)
    
    local parts = split(dwp, "/")
    if parts[1] ~= "file:" then
        if parts[1] == ".." then
            local parts2 = split(pagaddr, "/")
            parts[1]= parts2[1]..'//'..parts2[2]
            local dwp = restore(parts)
        end
        render.drawText(1, line, 0xFFFFFF, "Do you want to download file: "..parts[#parts].."? Y/N")
        line = line + 1
        render.update()
        while true do
            local _, _, _, key = ev.pull("key_up")
            if key == 21 then break
            elseif key == 49 then drawPage() return end
        end
        if component.isAvailable("internet") then
            intcard = component.internet
        else
            render.drawText(1, line, 0xFF0000, "Can't download file: no internet card")
            line = line + 2
            anyKey(line)
            return
        end
        local req = intcard.request(dwp)
        if not req then
            render.drawText(1, line, 0xFF0000, "Can't download file: nil request")
            line = line + 2
            anyKey(line)
            return
        end
        local stt = computer.uptime()
        while not req.finishConnect() do
            if computer.uptime() == stt + 10 then
                render.drawText(1, line, 0xFF0000, "Can't download file: timeout")
                line = line + 2
                anyKey(line)
                return
            elseif req.finishConnect() == nil then
                local err = table.pack(req.finishConnect())[2]
                if err:sub(0,12) == 'unknown host' then
                    render.drawText(1, line, 0xFF0000, "Can't download file: unknown host")
                elseif err == pagaddr then
                    render.drawText(1, line, 0xFF0000, "File not found on the server")
                else
                    render.drawText(1, line, 0xFF0000, err)
                end
                line = line + 2
                anyKey(line)
                return
            end
            os.sleep()
        end
        local code, msg = req.response()
        if code ~= 200 then
            render.drawText(1, line, 0xFF0000, "Server returned HTTP response code: "..math.floor(code)..", message: "..msg)
            line = line + 2
            anyKey(line)
            return
        end
        
        render.drawText(1, line, 0xFFFFFF, "Downloading file...")
        line = line + 1
        render.update()

        if not fs.isDirectory(config.downloadDir) then 
            fs.makeDirectory(config.downloadDir)
        end
        local savto = fs.concat(config.downloadDir, parts[#parts])
        local sav = io.open(savto, 'wb')
        local data = ''
        while data ~= nil do
            sav:write(data)
            data = req.read()		
        end
        sav:close()
        render.drawText(1, line, 0xFFFFFF, "File downloaded!")
        line = line + 2
        anyKey(line)
    else
        table.remove(parts, 1)
        dwp = '/'..restore(parts)
        local fil = io.open(dwp, 'rb')
        render.drawText(1, line, 0xFFFFFF, "Do you want to download file: "..parts[#parts].."? Y/N")
        line = line + 1
        render.update()
        while true do
            _, _, _, key = ev.pull("key_up")
            if key == 21 then break
            elseif key == 49 then return end
        end
        render.drawText(1, line, 0xFFFFFF, "Downloading file...")
        line = line + 1
        render.update()
        local savto = fs.concat(config.downloadDir, parts[#parts])
        local sav = io.open(savto, 'wb')
        local rded = fil:read()
        while rded ~= nil do
            sav:write(rded)
            rded = fil:read()
        end
        fil:close()
        sav:close()
        render.drawText(1, line, 0xFFFFFF, "File downloaded!")
        line = line + 2
        anyKey(line)
        end
end


local function journal(direct)
    hypjpos = hypjpos + direct
    loadPage(hypjour[hypjpos], true)
end


local function clickEvent(kX, kY)
    local function check(tbl, func)
        for _, ref in pairs(tbl) do
            local sec = ref[5] or ref[4]+1
            if ref[4] <= kY and kY < sec and ref[2] <= kX and kX < ref[3] then
                func(ref[1])
                return true
            end
        end
    end
    
    
    if kY == resY then
            if 42 <= kX and kX < resX-9 then
                enterUrl()
            elseif kX == 22 then
                loadPage(config.homepage)
            elseif kX == 25 and hypjpos ~= 1 then
                journal(-1)
            elseif kX == 28 then
                loadPage(pagaddr)
            elseif kX == 31 and hypjpos ~= #hypjour then
                journal(1)
            end
    elseif #hyper ~= 0 or #hyperdw ~= 0 then
        if check(hyper, loadPage) then return end
        check(hyperdw, downloadFile)
    end
end



print("Memphisto NFPL Browser v".._VER_)
print("Developing © 2020-2022 Compys S&N Systems")

if gpu.maxDepth() < 8 then
    print("FATAL ERROR! The program requires a Tier 3 video card and monitor")
    return
end
gpu.setDepth(8)
gpu.setResolution(resX, resY)

local rawconf, why = io.open("/etc/mmbrow.cfg")
if not rawconf then
    if why == "file not found" then
        local newconf, why = io.open("/etc/mmbrow.cfg", "w")
        if not newconf then
            print("FATAL ERROR! Can't create config file: "..why)
            return
        end
        
        local body = '{homepage = "file://usr/misc/Memphisto/home.nfp",\ndownloadDir = "/home/downloads",\nbackground = 0x878787,\nshowRam = false}'
        newconf:write(body)
        newconf:close()
        
        config = unser(body)
    else
        print("FATAL ERROR! Can't open config file: "..why)
        return
    end
else
    config, why = unser(rawconf:read("*a"))
    rawconf:close()
    
    if not config then
        print("FATAL ERROR! Can't handle config file: "..why)
        return
    end
end

pagaddr = args[1] or config.homepage

render.setGPUProxy(gpu)
render.clear(0)

table.insert(hypjour, pagaddr)
loadPage(pagaddr)

while true do
    local evt,_,x,key,sc = pull()
    if evt == "key_down" then
        if key == 200 then scrollPage(true, 1)
        elseif key == 208 then scrollPage(true, -1)
        elseif key == 203 then scrollPage(false, 1)
        elseif key == 205 then scrollPage(false, -1)
        elseif key == 59 then loadPage("file://usr/misc/Memphisto/help.nfp")
        elseif key == 61 then loadPage(config.homepage)
        elseif key == 62 then enterUrl()
        elseif key == 63 then loadPage(pagaddr)
        elseif key == 65 then picrendr = not picrendr drawPage() 
        end
    elseif evt == "interrupted" then
        gpu.setBackground(0x000000)
        gpu.setForeground(0xFFFFFF)
        term.clear()
        print("Thanks for using Memphisto!\n")
        os.exit()
    elseif evt == "scroll" then scrollPage(true, sc)
    elseif evt == "touch" then clickEvent(x, key)
    end
end
