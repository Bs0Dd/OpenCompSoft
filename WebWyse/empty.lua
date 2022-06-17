--WebWyse 1.0 installer by Compys S&N Systems (2022). 
--Configuration zone.

--Name of the product being installed.
local PRODUCTNAME = ''

--Strings for small background window. nil for disabled. Max 4 lines.
local BACKWINTEXT = {''}

--The text that will be shown in the console after a successful installation. nil for disabled.
local EXITNOTE = nil

--License for product. nil to use LICENSEURL or disabled.
local LICENSE = nil

--URL for license to download from network. nil for disabled.
local LICENSEURL = nil

--Default installation path. nil for empty.
local INSTALLPATH = nil

--Minimum space (in bytes) required for installation. nil for disable checking.
local MINSPACE = nil

--Minimal requirements for installation. nil for disable checking.
local MINREQ = {
    CPU = nil, --Minimal CPU tier required for installation. nil for disable checking.
    VIDEO = nil, --Minimal videosystem tier required for installation. nil for disable checking
    RAM = nil, --Minimum RAM size required for installation. nil for disable checking.
    COMPONENTS = nil --Components required for installation. nil for none.
}

--Colors for Tier 3 Videosystem.
local T3BACKCOL = 0xFFFFFF -- Color for the background.
local T3NORMALCOL = {0xFFFFFF, 0x006DFF} --Text and background colors for the windows.
local T3BUTTCOL = {0xFFFFFF, 0x5A5A5A} --Text and background colors for the buttons.
local T3FORMCOL = {0x000000, 0xE1E1E1} --Text and background colors for the forms (license view, path input).
local T3FSELCOL = {0xFFFFFF, 0x5A5A5A} --Text and background colors for selected item in the form.
local T3ERRCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for the error windows.
local T3REQOKCOL = {0x00FF00, 0x006DFF} --Text and background colors for components that meets minimal requirements.
local T3REQERCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for components that does not meet minimal requirements.
local T3PROGRBLK = 0xFFFFFF -- Color for the blank part of the progress bar.
local T3PROGRFIL = 0x00FF00 -- Color for the filled part of the progress bar.

--Colors for Tier 2 Videosystem.
local T2BACKCOL = 0xFFFFFF -- Color for the background.
local T2NORMALCOL = {0xFFFFFF, 0x006DFF} --Text and background colors for the windows.
local T2BUTTCOL = {0xFFFFFF, 0x3C3C3C} --Text and background colors for the buttons.
local T2FORMCOL = {0x000000, 0xE1E1E1} --Text and background colors for the forms (license view, path input).
local T2FSELCOL = {0xFFFFFF, 0x3C3C3C} --Text and background colors for selected item in the form.
local T2ERRCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for the error windows.
local T2REQOKCOL = {0x00FF00, 0x006DFF} --Text and background colors for components that meets minimal requirements.
local T2REQERCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for components that does not meet minimal requirements.
local T2PROGRBLK = 0xFFFFFF -- Color for the blank part of the progress bar.
local T2PROGRFIL = 0x00FF00 -- Color for the filled part of the progress bar.

--Colors for Tier 1 Videosystem. Not recommended to change.
local T1NORMALCOL = {0x000000, 0xFFFFFF} --Text and background colors for the windows.
local T1BUTTCOL = {0xFFFFFF, 0x000000} --Text and background colors for the buttons.
local T1FORMCOL = {0xFFFFFF, 0x000000} --Text and background colors for the forms (license view, path input).
local T1FSELCOL = {0x000000, 0xFFFFFF} --Text and background colors for selected item in the form.
local T1ERRCOL = {0x000000, 0xFFFFFF} --Text and background colors for the error windows.
local T1REQOKCOL = {0x000000, 0xFFFFFF} --Text and background colors for components that meets minimal requirements.
local T1REQERCOL = {0xFFFFFF, 0x000000} --Text and background colors for components that does not meet minimal requirements.
local T1PROGRBLK = 0x000000 -- Color for the blank part of the progress bar.
local T1PROGRFIL = 0xFFFFFF -- Color for the filled part of the progress bar.

--Basic files to download to your computer.
local FILES = {
    {
        url = "",
        path = "",
        absolute = false
    },
    {
        url = "",
        path = "",
        absolute = false
    }
}

--Additional components to download to your computer.
local ADDITIONAL = {
    {
        name = "",
        selected = true,
        size = 0,
        files = {
                 {
                    url = "",
                    path = "",
                    absolute = false
                 }
        }
    }
}

---------------------------------------------------------------------------------------------------------------

local comp = require('component')
local pc = require('computer')
local fs = require('filesystem')
local term = require('term')
local event = require('event')
local unicode = require('unicode')
local len = unicode.len
local sub = unicode.sub
local keyb = require('keyboard')
local gpu = comp.gpu

if not comp.isAvailable('internet') then
    io.stderr:write("ERROR: Internet card is not found\n\n")
    return
end
local internet = comp.internet

--------------------------------------------

local cx, cy = gpu.maxResolution()
gpu.setDepth(gpu.maxDepth())
gpu.setResolution(cx, cy)

local winx, winy = 1, 1
local step = 1
local stepsDraw, stepsEvent
local cachedlic, maxi
local licx, licy, limx = 1, 1, 1
local instpath = INSTALLPATH or ''
local cputier, vidtier, ram, comps 
local cpuok, vidok, ramok, compok, reqok = true, true, true, true
local cmy, csel, cdf = 1, 1, 1
local totf, fildwl, filsiz, filsdw, cfnam = 0, 0, 0, 0

if gpu.maxDepth() > 1 then
    winx, winy = math.ceil((cx-50)/2), math.ceil(cy/2)-4
end

local normcol, butcol, formcol, sformcol, errcol
local backcol, reqokcol, reqercol, problcol, proficol
if gpu.maxDepth() == 8 then
    normcol = T3NORMALCOL
    butcol = T3BUTTCOL
    formcol = T3FORMCOL
    sformcol = T3FSELCOL
    errcol = T3ERRCOL
    backcol = T3BACKCOL
    reqokcol = T3REQOKCOL
    reqercol = T3REQERCOL
    problcol = T3PROGRBLK
    proficol = T3PROGRFIL
elseif gpu.maxDepth() == 4 then
    normcol = T2NORMALCOL
    butcol = T2BUTTCOL
    formcol = T2FORMCOL
    sformcol = T2FSELCOL
    errcol = T2ERRCOL
    backcol = T2BACKCOL
    reqokcol = T2REQOKCOL
    reqercol = T2REQERCOL
    problcol = T2PROGRBLK
    proficol = T2PROGRFIL
else
    normcol = T1NORMALCOL
    butcol = T1BUTTCOL
    formcol = T1FORMCOL
    sformcol = T1FSELCOL
    errcol = T1ERRCOL
    backcol = normcol[2]
    reqokcol = T1REQOKCOL
    reqercol = T1REQERCOL
    problcol = T1PROGRBLK
    proficol = T1PROGRFIL
end

--------------------------------------------

local function setColor(cl)
    gpu.setForeground(cl[1])
    gpu.setBackground(cl[2])
end

--------------------------------------------

local function maxStrLen(strings)
    local leng = 0
    for _, v in ipairs(strings) do
        if len(v) > leng then leng = len(v) end
    end
    return leng
end

local function slines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

local function formatSize(size)
    local sizes = {"Kb", "Mb", "Gb"}
    if size < 1024 then return size .. "b" end
    local unit = 0
    while size >= 1024 and unit < #sizes do
        unit = unit + 1
        size = size / 1024
    end
    return math.floor(size * 10) / 10 .. sizes[unit]
end

--------------------------------------------

local function drawCentWin(x, y, tmlen, strings, colors)
    setColor(colors)
    gpu.set(x, y, string.rep(' ', tmlen+2))
    for k, v in ipairs(strings) do
        if len(v) < tmlen then
            local l, r = (tmlen - len(v))/2
            if l % 1 == 0 then
                r = l
            else
                l = math.ceil(l)
                r = l-1
            end
            v = string.rep(' ', l)..v..string.rep(' ', r)
        end
        gpu.set(x, y+k, ' '..v..' ')
    end
    if gpu.maxDepth() == 1 then return end
    gpu.set(x, y+#strings+1, string.rep(' ', tmlen+2))
    setColor({backcol, 0x000000})
    gpu.fill(x+tmlen+2, y+1, 1, #strings+1, ' ')
    gpu.set(x+2, y+#strings+2, string.rep('▄', tmlen+1))
end

--------------------------------------------

local function frontInit()
    local endx = winx+50
    setColor({backcol, 0x000000})
    gpu.fill(endx, winy+1, 1, 15, ' ')
    gpu.set(winx+2, winy+16, string.rep('▄', 49))
end

local function frontPrep()
    setColor(normcol)
    gpu.fill(winx, winy, 50, 16, ' ')
    gpu.fill(winx, winy, 50, 16, ' ')
    gpu.set(winx+2, winy+13, string.rep('─', 46))
end

local function drawBackLab(nofront)
    if BACKWINTEXT and gpu.maxDepth() > 1 then
        if #BACKWINTEXT > 4 then
            while #BACKWINTEXT > 4 do
                table.remove(BACKWINTEXT)
            end
        end
        local maxlen = maxStrLen(BACKWINTEXT)
        local x, y = math.ceil((cx-maxlen-2)/2), math.ceil(cy/10)-1
        drawCentWin(x, y, maxlen, BACKWINTEXT, normcol)
    end
    if not nofront then frontInit() end
end

local function smallDlg(text, color)
    table.insert(text, '')
    table.insert(text, '')
    gpu.setBackground(backcol)
    gpu.fill(1, 1, cx, cy, ' ')
    local maxlen = maxStrLen(text)
    local x, y = math.ceil((cx-maxlen)/2), math.ceil(cy/2)
    drawBackLab(true)
    drawCentWin(x, y, maxlen, text, color)
    return x, y, maxlen
end

local function smallInfoDlg(text, color)
    local x, y, maxlen = smallDlg(text, color)
    
    setColor(butcol)
    local keyx = math.ceil(x+(maxlen/2)-3)
    gpu.set(keyx, y+#text, "   Ok   ")
    
    while true do 
        local ev, _, mx, key = event.pull()
        if (ev == "key_down" and mx == 13) or
                (ev == "touch" and key == y+#text and mx >= keyx and mx <= keyx+7) then
            gpu.setBackground(backcol)
            gpu.fill(1, 1, cx, cy, ' ')
            drawBackLab()
            frontPrep()
            stepsDraw[step]()
            return
        end
    end
end

local function smallAlertDlg(text)
    local x, y = smallDlg(text, errcol)
        
    setColor(butcol)
    gpu.set(x+3, y+#text, " (Y)es  ")
    gpu.set(x+17, y+#text, "  (N)o  ")
    while true do 
        local ev, _, mx, key = event.pull()
        if ev == "key_down" then
            if mx == 78 or mx == 110 then
                drawBackLab()
                frontPrep()
                stepsDraw[step]()
                return true
            elseif mx == 89 or mx == 121 then
                return false
            end
        elseif ev == "touch" then
            if key == y+#text and mx >= x+3 and mx <= x+10 then
                return false
            elseif key == y+#text and mx >= x+17 and mx <= x+24 then
                drawBackLab()
                frontPrep()
                stepsDraw[step]()
                return true
            end
        end
    end
end

--------------------------------------------

local function exitInst(cancel)
    if cancel then
        if smallAlertDlg({" Are you sure you want to ", "abort the installation?"}) then return end
    end
    setColor({0xFFFFFF, 0x000000})
    term.clear()
    print("WebWyse 1.0 - 2022 (c) Compys S&N Systems\n")
    if not cancel and EXITNOTE then
        print(EXITNOTE.."\n")
    end
    os.exit()
end

--------------------------------------------

local function stepWelc()
    gpu.set(winx+6, winy+1, "Welcome to the WebWyse 1.0 installer!")
    gpu.set(winx+7, winy+3, "This installer will help to install")
    gpu.set(winx+25-(len(PRODUCTNAME)/2), winy+4, PRODUCTNAME)
    gpu.set(winx+17, winy+5, "on your computer.")
    gpu.set(winx+6, winy+8, "Follow WebWyse instructions to install")
    gpu.set(winx+12, winy+9, "and configure the software.")
    gpu.set(winx+10, winy+10, "Press \"Next →\" (→) to continue")
    gpu.set(winx+11, winy+11, "or \"Cancel\" (ALT-X) to exit.")
    
    setColor(butcol)
    gpu.set(winx+3, winy+14, " Cancel ")
    gpu.set(winx+39, winy+14, " Next → ")
end

local function welcEvent()
    while true do
        local ev, _, mx, key = event.pull()
        if ev == "key_down" then
            if keyb.isAltDown() and (mx == 88 or mx == 120) then
                exitInst(true)
            elseif key == 205 then
                return
            end
        elseif ev == "touch" then
            if key == winy+14 and mx >= winx+3 and mx <= winx+10 then exitInst(true) 
            elseif key == winy+14 and mx >= winx+39 and mx <= winx+46 then return end
        end
    end
end

--------------------------------------------

local function drawLicForm()
    gpu.fill(winx+3, winy+3, 44, 10, ' ')
    for i=0,9 do
        gpu.set(winx+3, winy+i+3, cachedlic[licy+i] and sub(cachedlic[licy+i], licx, licx+43) or '')
    end
end

local function downlLic()
    setColor(formcol)
    cachedlic = {"Loading from internet..."}
    drawLicForm()

    local bseerr = "Failed to get license text: "

    local pcsucc, handle = pcall(internet.request, LICENSEURL)
    if not pcsucc then LICENSE = bseerr..handle.."." return end
    if not handle then LICENSE = bseerr.."invalid URL-address." return end

    local stat, reas = handle.finishConnect()
    local time = pc.uptime()
    while stat == false do
        stat, reas = handle.finishConnect()
        if pc.uptime() > time + 40 then break end
    end

    if stat == nil then
        LICENSE = bseerr..(reas == LICENSEURL and "can't get file." or reas..".")
        return
    end

    local rcod, rcon = handle.response()
    local time = pc.uptime()
    while rcod == nil do
        rcod, rcon = handle.response()
        if pc.uptime() > time + 40 then break end
    end

    if rcod == nil then LICENSE = bseerr.."timeout expired." return
    elseif rcod ~= 200 then
        LICENSE = bseerr.."received code "..math.floor(rcod).." ("..rcon..")."
        return
    end
                    
    LICENSE = ""
                    
    while true do
        local data, reas = handle.read(math.huge)
        if data then
            LICENSE = LICENSE..data
        else
            handle:close()
            if reas then
                LICENSE = bseerr..reas.."."
            else
                return
            end
        end
    end
end

local function stepLic()
    gpu.set(winx+9, winy+1, "Do you agree with this license?")
    
    setColor(butcol)
    gpu.set(winx+3, winy+14, "  (N)o  ")
    gpu.set(winx+30, winy+14, " (B)ack ")
    gpu.set(winx+39, winy+14, " (Y)es  ")
    
    if not cachedlic then
        if not LICENSE and LICENSEURL then
            downlLic()
        end
        
        cachedlic = {}
        for str in slines(LICENSE) do
            table.insert(cachedlic, str)
        end
        limx = maxStrLen(cachedlic)
    end
    
    maxi = #cachedlic > 9 and #cachedlic - 9 or #cachedlic
    
    setColor(formcol)
    drawLicForm()
end

local function licEvent()
    while true do
        local ev, _, mx, key, sd = event.pull()
        if ev == "key_down" then
            if mx == 78 or mx == 110 then
                exitInst(true)
            elseif mx == 66 or mx == 98 then
                step = step - 2
                return
            elseif mx == 89 or mx == 121 then
                return
            elseif key == 200 then
                licy = (licy - 1 < 1) and 1 or licy - 1
                drawLicForm()
            elseif key == 208 then
                licy = (licy + 1 > maxi) and maxi or licy + 1
                drawLicForm()
            elseif key == 203 then
                licx = (licx - 1 < 1) and 1 or licx - 1
                drawLicForm()
            elseif key == 205 then
                licx = (licx + 1 > limx - 43) and limx - 43 or licx + 1
                drawLicForm()
            elseif key == 199 then
                licx = 1
                drawLicForm()
            elseif key == 207 then
                licx = limx - 43
                drawLicForm()
            elseif key == 201 then
                licy = (licy - 10 < 1) and 1 or licy - 10
                drawLicForm()
            elseif key == 209 then
                licy = (licy + 10 > maxi) and maxi or licy + 10
                drawLicForm()
            end
        elseif ev == "touch" then
            if key == winy+14 and mx >= winx+3 and mx <= winx+10 then
                exitInst(true)
            elseif key == winy+14 and mx >= winx+30 and mx <= winx+37 then
                step = step - 2
                return
            elseif key == winy+14 and mx >= winx+39 and mx <= winx+46 then
                return
            end
        elseif ev == "scroll" then
            licy = (licy - sd > maxi) and maxi or (licy - sd < 1) and 1 or licy - sd
            drawLicForm()
        end
    end
end

--------------------------------------------

local function difNotif(par1, par2, mode, flag)
    local text = {}
    
    if par1 == nil or (type(par1) == 'table' and #par1 == 0) then 
        text[1] = "Required: Not defined"
    elseif mode == 3 then
        local reqstr = "Required: "
        local havestr = "You have: "
        for _, val in pairs(par1) do
            if #reqstr+#val > 49 then
                table.insert(text, reqstr:sub(1, -2))
                reqstr = ""
            end
            reqstr = reqstr..val..", "
        end
        table.insert(text, reqstr:sub(1, -3))
        for _, val in pairs(par2) do
            if #havestr+#val > 49 then
                table.insert(text, havestr:sub(1, -2))
                havestr = ""
            end
            havestr = havestr..val..", "
        end
        table.insert(text, havestr:sub(1, -3))
    elseif mode == 2 then
        text[1] = "Required: "..formatSize(par1)
        text[2] = "You have: "..formatSize(par2)
    else
        text[1] = "Required: Tier "..par1
        text[2] = "You have: Tier "..par2
    end
    
    smallInfoDlg(text, flag and normcol or errcol)
end

local function checkSysReq()
    reqok = true
    
    if MINREQ.CPU and type(MINREQ.CPU) == 'number' then
        local pcinfo = pc.getDeviceInfo()
        for _, cmp in pairs(pcinfo) do
            if cmp.description == "CPU" or cmp.description == "APU" then
                cputier = tonumber(cmp.product:match('%d'))
                break
            end
        end
        cpuok = cputier >= MINREQ.CPU
        if not cpuok then reqok = false end
    end
    
    if MINREQ.VIDEO and type(MINREQ.VIDEO) == 'number' then
        local dept = gpu.maxDepth()
        vidtier = (dept == 8 and 3) or (dept == 4 and 2) or 1
        vidok = vidtier >= MINREQ.VIDEO
        if not vidok then reqok = false end
    end
    
    if MINREQ.RAM and type(MINREQ.RAM) == 'number' then
        ram = pc.totalMemory()
        ramok = ram >= MINREQ.RAM
        if not ramok then reqok = false end
    end
    
    if MINREQ.COMPONENTS and type(MINREQ.COMPONENTS) == 'table' then
        comps = {}
        for _, comn in pairs(MINREQ.COMPONENTS) do
            if comp.isAvailable(comn) then table.insert(comps, comn) end
        end
        compok = #comps == #MINREQ.COMPONENTS
        if not compok then reqok = false end
    end
    
    if reqok then
        gpu.set(winx+12, winy+1, "Your computer fully meets")
        
    else
        gpu.set(winx+11, winy+1, "Your computer does not meet")
        gpu.set(winx+5, winy+3, "Select the desired section for details.")
    end
    gpu.set(winx+12, winy+2, "the minimum requirements.")
    
    gpu.set(winx+10, winy+5, "(P)rocessor   :")
    gpu.set(winx+10, winy+7, "(M)emory      :")
    gpu.set(winx+10, winy+9, "(V)ideosystem :")
    gpu.set(winx+10, winy+11, "(С)omponents  :")
    
    local ords, i = {cpuok, ramok, vidok, compok}, 5
    
    for _, cmp in pairs(ords) do
        setColor(cmp and reqokcol or reqercol)
        gpu.set(winx+26, winy+i, cmp and "Meets" or "Does not meet")
        i = i + 2
    end
    
    setColor(butcol)
    gpu.set(winx+3, winy+14, " Cancel ")
    gpu.set(winx+30, winy+14, " ← Back ")
    gpu.set(winx+39, winy+14, " Next → ")
end

local function checkSysReqEvent()
    while true do
        local ev, _, mx, key, sd = event.pull()
        if ev == "key_down" then
            if keyb.isAltDown() and (mx == 88 or mx == 120) then
                exitInst(true)
            elseif key == 203 then
                step = step - 2
                return
            elseif key == 205 or mx == 13 then
                if reqok then return
                elseif not smallAlertDlg({"Are you sure you want to",
                                  "install this software?", "",
                                  "It may not work correctly!"}) then
                    drawBackLab()
                    frontPrep()
                    return
                end
            elseif mx == 112 or mx == 80 then
                difNotif(MINREQ.CPU, cputier, 1, cpuok)
            elseif mx == 109 or mx == 77 then
                difNotif(MINREQ.RAM, ram, 2, ramok)
            elseif mx == 118 or mx == 86 then
                difNotif(MINREQ.VIDEO, vidtier, 1, vidok)
            elseif mx == 99 or mx == 67 then
                difNotif(MINREQ.COMPONENTS, comps, 3, compok)
            end
        elseif ev == "touch" then
            if key == winy+14 and mx >= winx+3 and mx <= winx+10 then
                exitInst(true)
            elseif key == winy+14 and mx >= winx+30 and mx <= winx+37 then
                step = step - 2
                return
            elseif key == winy+14 and mx >= winx+39 and mx <= winx+46 then
                if reqok then return
                elseif not smallAlertDlg({"Are you sure you want to",
                                  "install this software?", "",
                                  "It may not work correctly!"}) then
                    drawBackLab()
                    frontPrep()
                    return
                end
            elseif key == winy+5 and mx >= winx+10 and mx <= winx+38 then
                difNotif(MINREQ.CPU, cputier, 1, cpuok)
            elseif key == winy+7 and mx >= winx+10 and mx <= winx+38 then
                difNotif(MINREQ.RAM, ram, 2, ramok)
            elseif key == winy+9 and mx >= winx+10 and mx <= winx+38 then
                difNotif(MINREQ.VIDEO, vidtier, 1, vidok)
            elseif key == winy+11 and mx >= winx+10 and mx <= winx+38 then
                difNotif(MINREQ.COMPONENTS, comps, 3, compok)
            end
        end
    end
end

--------------------------------------------

local function drawCompForm()
    gpu.fill(winx+3, winy+3, 44, 10, ' ')
    for i=0,(#ADDITIONAL-cdf < 9 and #ADDITIONAL-cdf or 9) do
        --gpu.set(1,i+1, ""..i.." "..cmy.." "..(i+1 == cmy and "thru" or "fals"))
        if i+1 == cmy then
            setColor(sformcol)
            gpu.fill(winx+3, winy+i+3, 44, 1, " ")
        end
        gpu.set(winx+6, winy+i+3, len(ADDITIONAL[cdf+i].name) > 39 and
                sub(ADDITIONAL[cdf+i].name, 0, 39)..".." or ADDITIONAL[cdf+i].name)
        if ADDITIONAL[cdf+i].selected then
            if gpu.maxDepth() > 1 then gpu.setForeground(0x00FF00) end
            gpu.set(winx+4, winy+i+3, "√")
        else
            if gpu.maxDepth() > 1 then gpu.setForeground(0xFF0000) end
            gpu.set(winx+4, winy+i+3, "╳")
        end
        if i+1 == cmy then
            gpu.setBackground(formcol[2])
        end
        gpu.setForeground(formcol[1])
    end
    
end

local function scomUp()
    if cdf > 1 then
        cdf = cdf - 1
        drawCompForm()
    else
        if cmy > 1 then
            cmy = cmy - 1
            drawCompForm()
        end
    end
end

local function scomDown()
    local max = #ADDITIONAL < 10 and #ADDITIONAL or 10
    if cmy + 1 > max then
        if cdf + 9 < #ADDITIONAL then
            cdf = cdf + 1
            drawCompForm()
        end
    else
        cmy = cmy + 1
        drawCompForm()
    end
end

local function addComps()
    gpu.set(winx+6, winy+1, "You can install additional components:")
    
    setColor(butcol)
    gpu.set(winx+3, winy+14, " Cancel ")
    gpu.set(winx+30, winy+14, " ← Back ")
    gpu.set(winx+39, winy+14, " Next → ")
    
    setColor(formcol)
    drawCompForm()
end

local function addCompsEvent()
    while true do
        local ev, _, mx, key, sd = event.pull()
        if ev == "key_down" then
            if keyb.isAltDown() and (mx == 88 or mx == 120) then
                exitInst(true)
            elseif key == 203 then
                step = step - 2
                return
            elseif key == 205 then
                return
            elseif key == 200 then
                scomUp()
            elseif key == 208 then
                scomDown()
            elseif key == 57 or key == 28 then
                ADDITIONAL[cmy+cdf-1].selected = not ADDITIONAL[cmy+cdf-1].selected
                drawCompForm()
            end
        elseif ev == "touch" then
            if key == winy+14 and mx >= winx+3 and mx <= winx+10 then
                exitInst(true)
            elseif key == winy+14 and mx >= winx+30 and mx <= winx+37 then
                step = step - 2
                return
            elseif key == winy+14 and mx >= winx+39 and mx <= winx+46 then
                return
            elseif key >= winy+3 and key <= winy+12 and mx >= winx+3 and mx <= winx+46 then
                ADDITIONAL[(key-winy-3)+cdf].selected = not ADDITIONAL[(key-winy-3)+cdf].selected
                drawCompForm()
            end
        elseif ev == "scroll" then
            if sd == 1 then scomUp() else scomDown() end
        end
    end
end

--------------------------------------------

local function checkPath()
    if instpath == "" then
        smallInfoDlg({"Installation path cannot be empty!", "Please enter the path."}, errcol)
        return false
    end
    
    if not fs.exists(instpath) then
        local res, prob = fs.makeDirectory(instpath)
        if not res then
            smallInfoDlg({"Failed to make directory:", prob..".",
                          "Please check if path is correct and try again."}, errcol)
            return false
        end
        return true
    end
    
    local disk = fs.get(instpath)
    if disk.isReadOnly() then
        smallInfoDlg({"This disk is write protected!", "Please unprotect the disk and try again."}, errcol)
        return false
    end
    
    if MINSPACE then
        local free = disk.spaceTotal() - disk.spaceUsed()
        if free < MINSPACE then
            smallInfoDlg({"Not enough space for installation!", 
                      "Please free at least "..formatSize(MINSPACE - free),
                      "of space and try again."}, errcol)
            return false
        end
    end
    return true
end

local function drawPathForm()
    local vi
    if len(instpath) > 43 then vi = '..'..sub(instpath, -41) else vi = instpath end
    term.setCursor(winx+3+len(vi), winy+9)
    gpu.fill(winx+3, winy+9, 44, 1, ' ')
    gpu.set(winx+3, winy+9, vi)
end

local function stepInsp()
    gpu.set(winx+4, winy+1, "Select a folder to install program files.")
    gpu.set(winx+3, winy+4, "Be aware that some files (such as libraries)")
    gpu.set(winx+8, winy+5, "may be installed in system folders.")
    gpu.set(winx+3, winy+8, "Install to:")
    
    local addsiz = MINSPACE or 0
    if ADDITIONAL and #ADDITIONAL > 0 then
        for _, cmp in pairs(ADDITIONAL) do
            if cmp.selected then addsiz = addsiz + cmp.size end
        end
    end
    
    if addsiz > 0 then gpu.set(winx+3, winy+11, "Space required: "..formatSize(addsiz)) end
    
    setColor(butcol)
    gpu.set(winx+3, winy+14, " Cancel ")
    gpu.set(winx+30, winy+14, " ← Back ")
    gpu.set(winx+39, winy+14, " Next → ")
    
    setColor(formcol)
    drawPathForm()
end

local function inspEvent()
    while true do
        local ev, _, mx, key, sd = term.pull()
        if ev == "key_down" then
            if keyb.isAltDown() and (mx == 88 or mx == 120) then
                exitInst(true)
            elseif key == 203 then
                step = step - 2
                return
            elseif key == 205 or mx == 13 then
                if checkPath() then return end
            elseif mx == 8 then
                instpath = sub(instpath,1,-2)
                drawPathForm()
            elseif mx == 0 or mx == 9 or mx == 127 then
            else
                instpath = instpath..unicode.char(mx)
                drawPathForm()
            end
        elseif ev == "touch" then
            if key == winy+14 and mx >= winx+3 and mx <= winx+10 then
                exitInst(true)
            elseif key == winy+14 and mx >= winx+30 and mx <= winx+37 then
                step = step - 2
                return
            elseif key == winy+14 and mx >= winx+39 and mx <= winx+46 then
                if checkPath() then return end
            end
        elseif eve == "clipboard" then 
            instpath = instpath..mx
            drawPathForm()
        end    
    end
end

--------------------------------------------

local function stepReady()
    gpu.set(winx+12, winy+1, "WebWyse is ready to install")
    gpu.set(winx+25-(len(PRODUCTNAME)/2), winy+2, PRODUCTNAME)
    gpu.set(winx+17, winy+3, "to your computer.")
    gpu.set(winx+9, winy+6, "Click \"Go\" to begin installation.")
    gpu.set(winx+13, winy+9, "Or click \"Back\" to change")
    gpu.set(winx+15, winy+10, "installation options.")
    
    setColor(butcol)
    gpu.set(winx+3, winy+14, " Cancel ")
    gpu.set(winx+30, winy+14, " ← Back ")
    gpu.set(winx+39, winy+14, "   Go   ")
end

local function readyEvent()
    while true do
        local ev, _, mx, key, sd = event.pull()
        if ev == "key_down" then
            if keyb.isAltDown() and (mx == 88 or mx == 120) then
                exitInst(true)
            elseif key == 203 then
                step = step - 2
                return
            elseif mx == 13 then
                return
            end
        elseif ev == "touch" then
            if key == winy+14 and mx >= winx+3 and mx <= winx+10 then
                exitInst(true)
            elseif key == winy+14 and mx >= winx+30 and mx <= winx+37 then
                step = step - 2
                return
            elseif key == winy+14 and mx >= winx+39 and mx <= winx+46 then
                return
            end
        end
    end
end

--------------------------------------------

local function drawProg()
    gpu.set(winx+2, winy+5, string.rep(" ", 46))
    gpu.set(winx+2, winy+7, string.rep(" ", 46))
    gpu.setForeground(normcol[1])
    local cfiltext = "Downloading file: "..cfnam
    if len(cfiltext) > 46 then cfiltext = cfiltext:sub(1,44)..".." end
    gpu.set(winx+25-(len(cfiltext)/2), winy+5, cfiltext)
    
    local ddattext = "Downloaded data: "..formatSize(filsdw).."/"..formatSize(filsiz)
    gpu.set(winx+25-(len(ddattext)/2), winy+7, ddattext)
    
    local totdtext = "Downloaded files: "..fildwl.."/"..totf
    gpu.set(winx+25-(len(totdtext)/2), winy+11, totdtext)
    
    gpu.setForeground(problcol)
    gpu.set(winx+4, winy+6, string.rep("━", 42))
    gpu.set(winx+4, winy+10, string.rep("━", 42))
    gpu.setForeground(proficol)
    if filsiz > 0 then
        local fp = math.ceil(42*(filsdw/filsiz))
        gpu.set(winx+4, winy+6, string.rep("━", fp))
    end
    local tp = math.ceil(42*(fildwl/totf))
    gpu.set(winx+4, winy+10, string.rep("━", tp))
end

local function downErr(err, text)
    smallInfoDlg({"Failed to "..err..":", text..".", "The installer will close."}, errcol)
end

local function stepDow()
    gpu.set(winx+9, winy+1, "WebWyse downloads the necessary")
    gpu.set(winx+13, winy+2, "files to your computer.")

    if ADDITIONAL then
        for _, cmp in pairs(ADDITIONAL) do
            if cmp.selected then
                for _, fil in pairs(cmp.files) do
                    table.insert(FILES, fil)
                end
            end
        end
    end
    totf = #FILES
end

local function dowEvent()
    for _, file in pairs(FILES) do
        cfnam = fs.name(file.path)
        drawProg()

        local fpath = file.absolute and file.path or fs.concat(instpath, file.path)
        if not fs.exists(fs.path(fpath)) then
            local succ, reas = fs.makeDirectory(fs.path(fpath))
            if not succ then
                downErr("create directory", reas)
                EXITNOTE = nil
                exitInst()
            end
        end

        local pfile, reas = io.open(fpath, "w")
        if not pfile then
            downErr("create file", reas)
            EXITNOTE = nil
            exitInst()
        end

        local pcsucc, handle = pcall(internet.request, file.url)
        if not pcsucc then
            downErr("make internet request", handle)
            EXITNOTE = nil
            exitInst()
        end
   
        if not handle then
            downErr("make internet request", "invalid URL-address")
            EXITNOTE = nil
            exitInst()
        end

        local stat, reas = handle.finishConnect()
        local time = pc.uptime()
        while stat == false do
            stat, reas = handle.finishConnect()
            if pc.uptime() > time + 40 then break end
        end
         
        if stat == nil then
            downErr("connect", reas == file.url and "can't get file" or reas)
            EXITNOTE = nil
            exitInst()
        end

        local rcod, rcon, rcdat = handle.response()
        local time = pc.uptime()
        while rcod == nil do
            rcod, rcon, rcdat = handle.response()
            if pc.uptime() > time + 40 then break end
        end

        if rcod == nil then
            downErr("connect", "timeout expired")
            EXITNOTE = nil
            exitInst()
        elseif rcod ~= 200 then
            downErr("connect", "received code "..math.floor(rcod).." ("..rcon..")")
            EXITNOTE = nil
            exitInst()
        end

        if rcdat and rcdat["Content-Length"] then
            filsiz = tonumber(rcdat["Content-Length"][1])
        else
            filsiz = 0
        end
        filsdw = 0
        drawProg()
        
        while true do
            local data, reas = handle.read(math.huge)
            if data then
                filsdw = filsdw + #data
                pfile:write(data)
                drawProg()
            else
                handle:close()
                if reas then
                    downErr("get file", reas)
                    EXITNOTE = nil
                    exitInst()
                else
                    pfile:close()
                    break
                end
            end
        end
        
        fildwl = fildwl + 1
        drawProg()
    end
end

--------------------------------------------

local function stepFin()
    gpu.set(winx+25-(len(PRODUCTNAME)/2), winy+4, PRODUCTNAME)
    gpu.set(winx+10, winy+5, "has been successfully installed")
    gpu.set(winx+17, winy+6, "on your computer.")
    gpu.set(winx+9, winy+9, "Click \"Ok\" to exit the installer.")
    
    setColor(butcol)
    gpu.set(winx+39, winy+14, "   Ok   ")
end

local function finEvent()
    while true do
        local ev, _, mx, key, sd = event.pull()
        if (ev == "key_down" and mx == 13) or
                (ev == "touch" and key == winy+14 and mx >= winx+39 and mx <= winx+46) then
            return
        end
    end
end

--------------------------------------------

gpu.setBackground(backcol)
gpu.fill(1, 1, cx, cy, ' ')

drawBackLab()


stepsDraw = {stepWelc}
stepsEvent = {welcEvent}

if LICENSE or LICENSEURL then
    table.insert(stepsDraw,  stepLic)
    table.insert(stepsEvent, licEvent)
end

if MINREQ and (MINREQ.CPU or MINREQ.VIDEO or MINREQ.RAM or MINREQ.COMPONENTS) then
    table.insert(stepsDraw, checkSysReq)
    table.insert(stepsEvent, checkSysReqEvent)
end

if ADDITIONAL and #ADDITIONAL > 0 then
    table.insert(stepsDraw, addComps)
    table.insert(stepsEvent, addCompsEvent)
end

table.insert(stepsDraw, stepInsp)
table.insert(stepsEvent, inspEvent)

table.insert(stepsDraw, stepReady)
table.insert(stepsEvent, readyEvent)

table.insert(stepsDraw, stepDow)
table.insert(stepsEvent, dowEvent)

table.insert(stepsDraw, stepFin)
table.insert(stepsEvent, finEvent)

while step <= #stepsDraw do
    frontPrep()
    stepsDraw[step]()
    stepsEvent[step]()
    step = step+1
end
exitInst()
