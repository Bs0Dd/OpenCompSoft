-- openfetch 1.1 | by ethernalsteve & Bs0Dd

local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local term = require("term")
local gpu = component.gpu

local logos = {
  {
    "  %%%%(///////(%%%    ",
    " %%###(///%%%/(%%%%%  ",
    " %%###(///%%%/(%%%%%  ",
    " %%###(///////(%%%%%  ",
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
      name = dev.product break
    end
  end
  return name
end

local function osDefinition()
  if fs.exists("/lib/core") then 
    return "OpenOS"
  elseif fs.exists("/root") then 
    return "Plan9k"
  end
  return ""
end

local function getParsedUptime()
  local seconds = math.floor(computer.uptime())
  local minutes, hours = 0, 0

  if seconds >= 60 then
    minutes = math.floor(seconds / 60)
    seconds = seconds % 60
  end
  if minutes >= 60 then
    hours = math.floor(minutes / 60)
    minutes = minutes % 60
  end
  if getGPUTier() == 1 then
    return string.format("|Uptime|: %02d:%02d:%02d", hours, minutes, seconds)
  else
    local time = "|Uptime|: "
    if hours == 1 then
      time = hours .. " hour, "    
    elseif hours >= 2 then
      time = hours .. " hours, " 
    end
    if minutes == 1 then
      time = time .. minutes .. " min, "
    elseif minutes >= 2 then
      time = time .. minutes .. " mins, "
    end
    time = time .. seconds .. " sec"
    return time
  end
end

local logo = logos[getGPUTier()]

local gcard = getModel('Graphics controller')
gcard = gcard..' '..'('..gcard:sub(4,4)..' Tier)'
local cpu = getModel('CPU')
cpu = cpu:sub(0, 12)..'('..cpu:sub(11,11)..' Tier)'
local trm = getModel('Text buffer')


local function addCharacteristics()
  logo[2] = logo[2] .. "|OS|: " .. osDefinition()
  logo[3] = logo[3] .. getParsedUptime()
  logo[4] = logo[4] .. "|CPU|: " .. cpu
  logo[5] = logo[5] .. "|Architecture|: " .. _VERSION
  logo[6] = logo[6] .. "|GPU|: " .. gcard
  logo[7] = logo[7] .. "|Terminal|: " .. trm
  logo[8] = logo[8] .. "|Resolution|: " .. math.floor(w) .. "x" .. math.floor(h)
  logo[9] = logo[9] .. "|Memory|: " .. math.floor(computer.totalMemory() / 1024 - computer.freeMemory() / 1024) .. " KB / " .. math.floor(computer.totalMemory() / 1024) .. " KB"
end

gpu.setResolution(w, h)
addCharacteristics()
gpu.fill(1,1,w,h,' ')
term.setCursor(1, #logo+2 > 14 and #logo+2 or 14)

for i = 1, #logo do
  local logoLine, tmp, f = {}, {}, false
  logo[i]:gsub(".",function(c) table.insert(logoLine,c) end)
  for ii = 1, #logoLine do
    if f then
      if string.match(logoLine[ii], "|") then
        f = false
      else
        if osDefinition() == "OpenOS" then
          gpu.setForeground(0x30ff80)
        elseif osDefinition() == "Plan9k" then
          gpu.setForeground(0xff0000)
        end
        gpu.set(ii, i, logoLine[ii])
      end
    else
      if logoLine[ii] == "%" then
        if osDefinition() == "OpenOS" then
          gpu.setForeground(0x228822)
        elseif osDefinition() == "Plan9k" then
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
  
  local palette = {{0x000000, 0x333333}, {0xCC0000, 0xFF0000}, {0x00CC00, 0x00FF00}, {0xCCCC00, 0xFFFF00},
                   {0x0000CC, 0x0000FF}, {0xCC00CC, 0xFF00FF}, {0x00CCCC, 0x00FFFF}, {0xCCCCCC, 0xFFFFFF}}
  local cur = #logo[1]+2
  for _, color in pairs(palette) do
  gpu.setForeground(color[1])
  gpu.set(cur, 11, '███')
  gpu.setForeground(color[2])
  gpu.set(cur, 12, '███')
  cur = cur+3
  end

end