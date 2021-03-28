local pc = computer
local cm = component
local rom=cm.proxy(cm.list("eeprom")())
if cm.list("gpu")() == nil then error('Ow, where is Video Card?') end
local vid=cm.proxy(cm.list("gpu")())
if vid.maxDepth() > 1 then error("It's version for Tier 1 Video Card only!") end
if cm.list("redstone")() == nil then error('Redstone device is not found in system!') end
local red=cm.proxy(cm.list("redstone")())
local mx, my = vid.getResolution()
local vfl = vid.fill
vfl(1, 1, mx, my, " ")
vid.setResolution(40,20)
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
  vsb(1)
  vfl(1,1,40,5, " ")
  vsf(0)
  vst(8,1,'SecuCODEX Code Door System')
  if preset == 1 then
    local npos = (40-10-#who)/2
    if (40-10-#who)%2 ~= 0 then npos = npos + 1 end
    vst(math.floor(npos)+1,3,'Welcome, '..who..'!')
  elseif preset == 3 then
    vst(14,3,'ACCESS DENIED!')
  end
end

local function drawfinger()
  vsb(0)
  vsf(1)
  vst(30,9 , '╔═════════╗')
  vst(30,10, '║Finger   ║')
  vst(30,11, '║   print ║')
  vst(30,12, '║ Scanner ║')
  vst(30,13, '║Compys   ║')
  vst(30,14, '║ OCFPS-35║')
  vst(30,15, '╚═════════╝')
end

local function drawbut(x,y,n,noinv)
  local function key()
	vst(x,y  , '╔═════╗')
    vst(x,y+1, '║  '..n..'  ║')
    vst(x,y+2, '╚═════╝')
  end
  if not noinv then
    vsb(1)
    vsf(0)
	key()
    sleep(0.1)
  end
  vsb(0)
  vsf(1)
  key()
end

local function drawkeys()
  local t = true
  drawbut(3,7,1,t)
  drawbut(12,7,2,t)
  drawbut(21,7,3,t)
  drawbut(3,10,4,t)
  drawbut(12,10,5,t)
  drawbut(21,10,6,t)
  drawbut(3,13,7,t)
  drawbut(12,13,8,t)
  drawbut(21,13,9,t)
  drawbut(3,16,'C',t)
  drawbut(12,16,0,t)
  drawbut(21,16,'E',t)
end

local function finger()
  vsb(0)
  vsf(1)
  local rr=14
  while rr ~=10 do
    vst(31,rr, '─────────')
    sleep(0.05)
    vst(31,rr, '         ')
    rr=rr-1
  end
  while rr ~=14 do
    vst(31,rr, '─────────')
    sleep(0.05)
    vst(31,rr, '         ')
    rr=rr+1
  end
  sleep(0.05)
  vst(31,10, '█████████')
  vst(31,11, '█  ████ █')
  vst(31,12, '█ █ █ █ █')
  vst(31,13, '█ █ █ █ █')
  vst(31,14, '█████████')
end

local function know(tpoint, who)
  if 2 < tpoint[1] and tpoint[1] < 10 and 6 < tpoint[2] and tpoint[2] < 10 then return 3,7,1
  elseif 11 < tpoint[1] and tpoint[1] < 19 and 6 < tpoint[2] and tpoint[2] < 10 then return 12,7,2
  elseif 20 < tpoint[1] and tpoint[1] < 28 and 6 < tpoint[2] and tpoint[2] < 10 then return 21,7,3
  elseif 2 < tpoint[1] and tpoint[1] < 10 and 9 < tpoint[2] and tpoint[2] < 13 then return 3,10,4
  elseif 11 < tpoint[1] and tpoint[1] < 19 and 9 < tpoint[2] and tpoint[2] < 13 then return 12,10,5
  elseif 20 < tpoint[1] and tpoint[1] < 28 and 9 < tpoint[2] and tpoint[2] < 13 then return 21,10,6
  elseif 2 < tpoint[1] and tpoint[1] < 10 and 12 < tpoint[2] and tpoint[2] < 16 then return 3,13,7
  elseif 11 < tpoint[1] and tpoint[1] < 19 and 12 < tpoint[2] and tpoint[2] < 16 then return 12,13,8
  elseif 20 < tpoint[1] and tpoint[1] < 28 and 12 < tpoint[2] and tpoint[2] < 16 then return 21,13,9
  elseif 2 < tpoint[1] and tpoint[1] < 10 and 15 < tpoint[2] and tpoint[2] < 19 then return 3,16,'C'
  elseif 11 < tpoint[1] and tpoint[1] < 19 and 15 < tpoint[2] and tpoint[2] < 19 then return 12,16,0
  elseif 20 < tpoint[1] and tpoint[1] < 28 and 15 < tpoint[2] and tpoint[2] < 19 then return 21,16,'E' 
  elseif tpoint[1] == 16 and tpoint[2] == 20 and who then
    vsb(0)
    vsf(1)
    vfl(1,1,40,5, " ")
    vst(1,1,'SecuCODEX Mono Edition v1.1 Setup')
    vst(1,2,'Old Password: ')
    local apassw = ''
    local pos = 1
    while true do
      local _,_,tx,ty,_,who = toucheve()
      local tpoint = {tx,ty}
      local x,y,n = know(tpoint)
      if n ~= nil then
      drawbut(x,y,n)
        if n== 'C' then apassw='' vfl(14, 2, 40, 1, " ") pos =1
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
      if 29 < tpoint[1] and tpoint[1] < 41 and 8 < tpoint[2] and tpoint[2] < 16 then
        finger()
        for _,name in pairs(allowed) do
          if who == name then return 500,500,'E',passw end
        end
        return 500,500,'E',''
      end
  end
end 

local function intap()
  vsb(0)
  vsf(1)
  vfl(1,1,40,5, " ")
  vst(1,1,'SecuCODEX Mono Edition v1.1 Setup')
  vst(1,2,'New Password: ')
  local passw = ''
  drawkeys()
  local pos = 1
  local function prp() vfl(1,2,40,5, " ") end
  while true do
    local _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n = know(tpoint, true)
    if n ~= nil then
      drawbut(x,y,n)
      if n== 'C' then passw='' vfl(14, 2, 40, 1, " ") pos =1
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
      if n== 'C' then corr='' vfl(29, 2, 40, 1, " ") pos =1
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
      if n== 'C' then incorr='' vfl(31, 2, 40, 1, " ") pos =1
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

vst(5,20,'2020-2021 (c) Compys S&N Systems')
drawplate(2)
while true do
  local inpassw=''
  local see=''
  drawkeys()
  drawfinger()
  local pos = 1
  local prept = 21
  local _,tx,ty,who
  while true do
    _,_,tx,ty,_,who = toucheve()
    local tpoint = {tx,ty}
    local x,y,n,q = know(tpoint, who)
    if n ~= nil then
      if kpush =='true' then drawbut(x,y,n) end
      vsb(1)
      vsf(0)
      if n== 'C' then inpassw='' see='' vfl(1, 3, 40, 1, " ") pos =1 prept = 21
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
        vst(prept,3,see)
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