local pc = computer
local cm = component
local rom=cm.proxy(cm.list("eeprom")())
if cm.list("gpu")() == nil then error('Ow, where is Video Card?') end
local vid=cm.proxy(cm.list("gpu")())
if vid.maxDepth() == 1 then error('Tier 1 Video Card is not supported!') end
if cm.list("redstone")() == nil then error('Redstone device is not found in system!') end
local red=cm.proxy(cm.list("redstone")())
local mx, my = vid.getResolution()
local vfl = vid.fill
vfl(1, 1, mx, my, " ")
vid.setResolution(60,30)
mx, my = vid.getResolution()
local rawsect, allowed, passw, stars, kpush, corr, incorr= rom.getData(), {}
local vst = vid.set
local vsb = vid.setBackground
local vsf = vid.setForeground
local rso = red.setOutput

local function totable(inputstr)
  local t={}
   for str in string.gmatch(inputstr, "([^\n]+)") do
     table.insert(t, str)
   end
   return t
end

local function untable(table)
  local res= ''
  for _,x in pairs(table) do
    res= res..x..'\n'
  end
  return res
end

local function toucheve()
  local eve,w,tx,ty,z,who 
  while true do
    eve,w,tx,ty,z,who = pc.pullSignal()
    if eve == 'touch' then break end
  end
  return eve,w,tx,ty,z,who
end

local function sleep(timeout)
  local deadline = pc.uptime() + (timeout or 0)
  repeat
    pc.pullSignal(deadline - pc.uptime())
  until pc.uptime() >= deadline
end

local function drawplate(preset, who)
 local vmax = vid.maxDepth()
 local function tx() vst(18,1,'SecuCODEX Code Door System') end
   if preset == 1 then
	if vmax == 4 then
      vsb(5, true)
      vsf(15, true)
	else
	  vsb(0x00FF00)
	  vsf(0x000000)
	end
	vfl(1,1,60,7, " ")
    tx()
    local npos = (61-10-#who)/2
    if (61-10-#who)%2 ~= 0 then npos = npos + 1 end
    vst(math.floor(npos),4,'Welcome, '..who..'!')
	if vmax == 4 then
      vsb(13, true)
      vfl(1,8,60,1, " ")
      vsb(7, true)
	else
	  vsb(0x009200)
      vfl(1,8,60,1, " ")
      vsb(0x006D00)
	end
	vfl(1,9,60,1, " ")
  end
  if preset == 2 then
	if vmax == 4 then
      vsb(0, true)
      vsf(15, true)
	else
	  vsb(0xFFFFFF)
      vsf(0x000000)
	end
	vfl(1,1,60,7, " ")
    tx()
	if vmax == 4 then
      vsb(8, true)
      vfl(1,8,60,1, " ")
      vsb(7, true)
	else
	  vsb(0xC3C3C3)
      vfl(1,8,60,1, " ")
      vsb(0x969696)
	end
    vfl(1,9,60,1, " ")
  end
  if preset == 3 then
	if vmax == 4 then
      vsb(14, true)
      vsf(15, true)
	else
	  vsb(0xFF0000)
      vsf(0x000000)
	end
	vfl(1,1,60,7, " ")
    tx()
    vst(23,4,'ACCESS DENIED!')
	if vmax == 4 then
      vsb(12, true)
      vfl(1,8,60,1, " ")
      vsb(7, true)
	else
	  vsb(0x990000)
      vfl(1,8,60,1, " ")
      vsb(0x660000)
	end
    vfl(1,9,60,1, " ")
  end
 vsb(0x000000)
 vsf(0xFFFFFF)
end

local function drawfinger()
  vsb(0x000000)
  vsf(0xFF0000)
  vst(43,16, '╔═════════════╗')
  vst(43,17, '║ Finger      ║')
  vst(43,18, '║       print ║')
  vst(43,19, '║  Scanner    ║')
  vst(43,20, '║             ║')
  vst(43,21, '║ Compys      ║')
  vst(43,22, '║   OCFPS-412 ║')
  vst(43,23, '╚═════════════╝')
end

local function drawbut(x,y,n,noinv)
  local function key()
    vst(x,y  , '╔═══════╗')
    vst(x,y+1, '║       ║')
    vst(x,y+2, '║   '..n..'   ║')
    vst(x,y+3, '║       ║')
    vst(x,y+4, '╚═══════╝')
  end
  if not noinv then
    vsb(0xFF0000)
    vsf(0x000000)
	key()
    sleep(0.1)
  end
  vsb(0x000000)
  vsf(0xFF0000)
  key()
end

local function drawkeys()
  local t = true
  drawbut(6,10,1,t)
  drawbut(18,10,2,t)
  drawbut(30,10,3,t)
  drawbut(6,15,4,t)
  drawbut(18,15,5,t)
  drawbut(30,15,6,t)
  drawbut(6,20,7,t)
  drawbut(18,20,8,t)
  drawbut(30,20,9,t)
  drawbut(6,25,'C',t)
  drawbut(18,25,0,t)
  drawbut(30,25,'E',t)
end

local function finger()
  vsb(0x000000)
  vsf(0xFF0000)
  local rr=22
  while rr ~=17 do
    vst(44,rr, '─────────────')
    sleep(0.05)
    vst(44,rr, '             ')
    rr=rr-1
  end
  while rr ~=22 do
    vst(44,rr, '─────────────')
    sleep(0.05)
    vst(44,rr, '             ')
    rr=rr+1
  end
  sleep(0.05)
  vst(44,17, ' ███████████ ')
  vst(44,18, ' █   ████  █ ')
  vst(44,19, ' █  █   █  █ ')
  vst(44,20, ' █  █ █ ██ █ ')
  vst(44,21, ' █ ██ █ █  █ ')
  vst(44,22, ' ███████████ ')
end

local function know(tpoint, who)
  if 5 < tpoint[1] and tpoint[1] < 16 and 9 < tpoint[2] and tpoint[2] < 15 then return 6,10,1
  elseif 17 < tpoint[1] and tpoint[1] < 27 and 9 < tpoint[2] and tpoint[2] < 15 then return 18,10,2
  elseif 29 < tpoint[1] and tpoint[1] < 39 and 9 < tpoint[2] and tpoint[2] < 15 then return 30,10,3
  elseif 5 < tpoint[1] and tpoint[1] < 16 and 14 < tpoint[2] and tpoint[2] < 20 then return 6,15,4
  elseif 17 < tpoint[1] and tpoint[1] < 27 and 14 < tpoint[2] and tpoint[2] < 20 then return 18,15,5
  elseif 29 < tpoint[1] and tpoint[1] < 39 and 14 < tpoint[2] and tpoint[2] < 20 then return 30,15,6
  elseif 5 < tpoint[1] and tpoint[1] < 16 and 19 < tpoint[2] and tpoint[2] < 25 then return 6,20,7
  elseif 17 < tpoint[1] and tpoint[1] < 27 and 19 < tpoint[2] and tpoint[2] < 25 then return 18,20,8
  elseif 29 < tpoint[1] and tpoint[1] < 39 and 19 < tpoint[2] and tpoint[2] < 25 then return 30,20,9
  elseif 5 < tpoint[1] and tpoint[1] < 16 and 24 < tpoint[2] and tpoint[2] < 30 then return 6,25,'C'
  elseif 17 < tpoint[1] and tpoint[1] < 27 and 24 < tpoint[2] and tpoint[2] < 30 then return 18,25,0
  elseif 29 < tpoint[1] and tpoint[1] < 39 and 24 < tpoint[2] and tpoint[2] < 30 then return 30,25,'E' 
  elseif tpoint[1] == 26 and tpoint[2] == 30 and who then
    vsb(0x000000)
    vsf(0xFFFFFF)
    vfl(1,1,60,9, " ")
    vst(1,1,'SecuCODEX Color Edition v1.1 Setup')
    vsf(0xFF0000)
    vst(1,2,'Old Password: ')
    local apassw = ''
    local pos = 1
    while true do
      local _,_,tx,ty,_,who = toucheve()
      local tpoint = {tx,ty}
      local x,y,n = know(tpoint)
      if n ~= nil then
      drawbut(x,y,n)
        if n== 'C' then apassw='' vfl(14, 2, 60, 1, " ") pos =1
        elseif n== 'E' then break
        else
          pos = pos+1
          apassw = apassw..n
          vst(pos+13,2, "*")
        end
      end
    end
    if apassw == passw then rom.setData('') pc.shutdown(true) else drawplate(2) end
  elseif who then 
      if 43 < tpoint[1] and tpoint[1] < 56 and 16 < tpoint[2] and tpoint[2] < 23 then
        finger()
        for _,name in pairs(allowed) do
          if who == name then return 500,500,'E',passw end
        end
        return 500,500,'E',''
      end
  end
end 

local function intap()
  vsb(0x000000)
  vsf(0xFFFFFF)
  vfl(1,1,60,8, " ")
  vst(1,1,'SecuCODEX Color Edition v1.1 Setup')
  vsf(0xFF0000)
  vst(1,2,'New Password: ')
  local passw = ''
  drawkeys()
  local pos = 1
  local function prp() vfl(1,2,60,8, " ") end
  while true do
    local _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n = know(tpoint, true)
    if n ~= nil then
      drawbut(x,y,n)
      if n== 'C' then passw='' vfl(14, 2, 60, 1, " ") pos =1
      elseif n== 'E' then break
      else
        pos = pos+1
        passw = passw..n
        vst(pos+13,2, "*")
      end
    end
  end
  prp()
  vst(1,2,'Side for correct code (0-5): ')
  local corr = ''
  pos = 1
  while true do
    local _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n = know(tpoint, true)
    if n ~= nil then
      drawbut(x,y,n)
      if n== 'C' then corr='' vfl(29, 2, 60, 1, " ") pos =1
      elseif n== 'E' then break
      else
        pos = pos+1
        corr = corr..n
        vst(pos+28,2, tostring(n))
      end
    end
  end
  prp()
  vst(1,2,'Side for incorrect code (0-5): ')
  local incorr = ''
  pos = 1
  while true do
    local _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n = know(tpoint, true)
    if n ~= nil then
      drawbut(x,y,n)
      if n== 'C' then incorr='' vfl(31, 2, 60, 1, " ") pos =1
      elseif n== 'E' then break
      else
        pos = pos+1
        incorr = incorr..n
        vst(pos+30,2, tostring(n)) 
      end
    end
  end
  prp()
  vst(1,2,'Show password? [E/C]: ')
  while true do
    local _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n = know(tpoint, true)
    if n ~= nil then
      drawbut(x,y,n)
      if n== 'C' then stars = 'false' break
      elseif n== 'E' then stars = 'true' break
      end
    end
  end
  prp()
  vst(1,2,'Show key push? [E/C]: ')
  while true do
    local _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n = know(tpoint)
    if n ~= nil then
      drawbut(x,y,n)
      if n== 'C' then kpush = 'false' break
      elseif n== 'E' then kpush = 'true' break 
      end
    end
  end
  rom.setData(passw..'\n'..stars..'\n'..kpush..'\n'..corr..'\n'..incorr..'\n')
  pc.shutdown(true)
end

if rawsect~=nil and rawsect~='' then
  local rd = totable(rawsect)
  if #rd < 5 then intap() end
  passw, stars, kpush, corr, incorr = table.unpack(rd)
  local y=6
  while y-1~=#rd do table.insert(allowed,rd[y]) y=y+1 end
else
  intap()
end

drawplate(2)
vsf(0x00FF00)
vst(15,30,'2020-2021 (c) Compys S&N Systems')
while true do
  local inpassw=''
  local see=''
  drawkeys()
  drawfinger()
  local pos = 1
  local prept = 31
  local _,tx,ty,who
  while true do
    _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n,q = know(tpoint, who)
    if n ~= nil then
      if kpush =='true' then drawbut(x,y,n) end
      vsb(0xFFFFFF)
      vsf(0x000000)
      if n== 'C' then inpassw='' see='' vfl(1, 4, 60, 1, " ") pos =1 prept = 31
      elseif n== 'E' then sleep(0.1) if q then inpassw = q end break
      else
        pos = pos+1
        if pos % 2 == 0 then prept= prept-1 end
        inpassw = inpassw..n
        if stars == 'false' then
          see= see..'*'
        else
          see= see..n
        end
        vst(prept,4,see)
      end
    end
  end
  if inpassw == passw then
    drawplate(1, who)
    rso(tonumber(corr), 15)
	local exis
    for _,name in pairs(allowed) do
      if who == name then exis=true break end
    end
    if exis~=true then table.insert(allowed, who)
      rom.setData(passw..'\n'..stars..'\n'..kpush..'\n'..corr..'\n'..incorr..'\n'..untable(allowed)) end
    exis= nil
  else
    drawplate(3)
    rso(tonumber(incorr), 15)
  end
  sleep(1)
  drawplate(2)
  rso(tonumber(corr), 0)
  rso(tonumber(incorr), 0)
end