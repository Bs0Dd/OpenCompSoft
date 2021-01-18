-- openfetch 1.3 | by ethernalsteve & Bs0Dd

local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local term = require("term")
local gpu = component.gpu

local logos = {
    {
        "  %%%%(///////(%%%    ",
        " %%   (///%%%/(%%%%%  ",
        " %%   (///%%%/(%%%%%  ",
        " %%   (///////(%%%%%  ",
        " %%%%%%%%%%%%%%%%%%%  ",
        " %%%%%%%%%%%%%%%%%%%  ",
        " %%               %%  ",
        " %%               %%  ",
        " %%%%%%%%%%%%%%%%%%%  ",
        "  %%%%%%%%%%%%%%%%%   "
    },
    {
        "  %%%%%(///////////////(%%%%      ",
        " %%%###(//////%%%%%%///(%%%%%%%   ",
        " %%%###(//////%%%%%%///(%%%%%%%   ",
        " %%%###(//////%%%%%%///(%%%%%%%   ",
        " %%%###(//////%%%%%%///(%%%%%%%   ",
        " %%%###(///////////////(%%%%%%%   ",
        " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
        " %%%((((((((((((((((((((((((%%%   ",
        " %%%((((((((((((((((((((((((%%%   ",
        " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
        " %%%                        %%%   ",
        " %%%////////////////////////%%%   ",
        " %%%                        %%%   ",
        " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
        "  %%%%%%%%%%%%%%%%%%%%%%%%%%%%    "
    },
    {
        "  %%%%%%%%%%(///////////////////////(%%%%%%%      ",
        " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%    ",
        " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
        " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
        " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
        " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
        " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
        " %%%%%%#####(///////////////////////(%%%%%%%%%%   ",
        " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
        " %%%%%%((((((((((((((((((((((((((((((((((%%%%%%   ",
        " %%%%%%((((((((((((((((((((((((((((((((((%%%%%%   ",
        " %%%%%%((((((((((((((((((((((((((((((((((%%%%%%   ",
        " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
        " %%%%%%                                  %%%%%%   ",
        " %%%%%%                                  %%%%%%   ",
        " %%%%%%                                  %%%%%%   ",
        " %%%%%%//////////////////////////////////%%%%%%   ",
        " %%%%%%                                  %%%%%%   ",
        " %%%%%%                                  %%%%%%   ",
        " %%%%%%                                  %%%%%%   ",
        " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
        "  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    "
    }
}

local w, h = gpu.maxResolution()
local devs = component.computer.getDeviceInfo()
local gpuInfoStr

local function getGPUTier()
    local dp = gpu.maxDepth()
    if dp == 8 then
        return 3
    elseif dp == 4 then
        return 2
    else
        return 1
    end
end

local function getModel(desc)
    local name
    for _, dev in pairs(devs) do
        if dev.description == desc then
            name = dev.product
            break
        end
    end
    return name
end

local function getOS()
    if fs.exists("/lib/core") then
        return "OpenOS"
    elseif fs.exists("/root") then
        return "Plan9k"
    end
end

local function getParsedUptime()
    local seconds, minutes, hours = math.floor(computer.uptime()), 0, 0
    local time = ""
    if seconds >= 60 then
        minutes = math.floor(seconds / 60)
        seconds = seconds % 60
    end
    if minutes >= 60 then
        hours = math.floor(minutes / 60)
        minutes = minutes % 60
    end
    if getGPUTier() == 1 then
        time = time .. string.format("%02d:%02d:%02d", hours, minutes, seconds)
    else
        if hours == 1 then time = hours .. " hour, "
        elseif hours >= 2 then time = hours .. " hours, "
        end
        if minutes == 1 then time = time .. minutes .. " min, "
        elseif minutes >= 2 then time = time .. minutes .. " mins, "
        end
        time = time .. seconds .. " sec"
    end
    return time
end

local logo = logos[getGPUTier()]
local function addCharacteristics()
    local cpu, apu = getModel("CPU"), getModel("APU")
    gpuInfoStr = 8

    logo[2] = logo[2] .. "|OS:|" .. getOS()
    logo[3] = logo[3] .. "|Uptime:|" .. getParsedUptime()
    logo[4] = logo[4] .. "|Architecture:|" .. _VERSION
    logo[5] = logo[5] .. "|Resolution:|" .. math.floor(w) .. "x" .. math.floor(h)
    logo[6] = logo[6] .. "|Terminal:|" .. getModel("Text buffer")
    if cpu ~= nil then logo[7] = logo[7] .. "|CPU:|" .. cpu:sub(0,11) .. ' (' .. cpu:match('%d') .. ' Tier)'
    elseif apu ~= nil then logo[7] = logo[7] .. "|APU:|" .. apu:sub(0,11) .. ' (' .. apu:match('%d') .. ' Tier)' end
    for _, dev in pairs(devs) do
        if dev.description == "Graphics controller" then
            logo[gpuInfoStr] = logo[gpuInfoStr] .. "|GPU:|" .. dev.product .. ' (' .. dev.product:match('%d') .. ' Tier)'
            gpuInfoStr = gpuInfoStr + 1
        end
    end
    logo[gpuInfoStr] = logo[gpuInfoStr] .. "|Memory:|" .. math.floor(computer.totalMemory() / 1024 - computer.freeMemory() / 1024) .. " KB / " .. math.floor(computer.totalMemory() / 1024) .. " KB"
end

local function drawPalette()
    local palette = {{0x000000, 0x333333}, {0xCC0000, 0xFF0000}, {0x00CC00, 0x00FF00}, {0xCCCC00, 0xFFFF00},
        {0x0000CC, 0x0000FF}, {0xCC00CC, 0xFF00FF}, {0x00CCCC, 0x00FFFF}, {0xCCCCCC, 0xFFFFFF}}
    local cur = #logo[1] + 2
    for _, color in pairs(palette) do
        gpu.setForeground(color[1])
        gpu.set(cur, gpuInfoStr + 2, "███")
        gpu.setForeground(color[2])
        gpu.set(cur, gpuInfoStr + 3, "███")
        cur = cur + 3
    end
end

gpu.setResolution(w, h)
addCharacteristics()
gpu.fill(1, 1, w, h, " ")
term.setCursor(1, #logo + 2 > 14 and #logo + 2 or 14)

for i = 1, #logo do
    local logoLine, tmp, f = {}, {}, false
    logo[i]:gsub(".", function(c) table.insert(logoLine, c) end)
    for ii = 1, #logoLine do
        if f then
            if string.match(logoLine[ii], "|") then
                f = false
            else
                if string.match(logoLine[ii], ":") then
                    gpu.setForeground(0xffffff)
                elseif getOS() == "OpenOS" then
                    gpu.setForeground(0x30ff80)
                elseif getOS() == "Plan9k" then
                    gpu.setForeground(0xff0000)
                end
                gpu.set(ii, i, logoLine[ii])
            end
        else
            if logoLine[ii] == "%" then
                if getOS() == "OpenOS" then
                    gpu.setForeground(0x228822)
                elseif getOS() == "Plan9k" then
                    gpu.setForeground(0xff0000)
                end
                gpu.set(ii, i, logoLine[ii])
            elseif logoLine[ii] == "/" then
                gpu.setForeground(0xfffafa)
                gpu.set(ii, i, logoLine[ii])
            elseif logoLine[ii] == "#" then
                gpu.setForeground(0x585858)
                gpu.set(ii, i, logoLine[ii])
            elseif logoLine[ii] == "(" then
                gpu.setForeground(0xc0c0c0)
                gpu.set(ii, i, logoLine[ii])
            elseif string.match(logoLine[ii], "|") then
                f = true
            else
                gpu.setForeground(0xffffff)
                gpu.set(ii, i, logoLine[ii])
            end
        end
    end
end

drawPalette()

