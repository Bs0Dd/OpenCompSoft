--[[ SecuCODEX Code Door System.
     Mono Edition
Program-system for password and "fingerprint" based monochrome access computer system
ONLY FOR TIER 1 VIDEO CARD
Author: Bs()Dd

Idea and base interface concept borrowed from ECS's CodeDoor

Program-system working without OpenOS, because "hackers" can't kill it by CTRL+ALT+C

Requirements to computer system:
 - Tier 1 Computer
 - Tier 1 Video Card
 - Tier 2 Monitor (Tier 1 don't have touchscreen)
 - Tier 1 Processor
 - Tier 1 Hard Drive
 - 1x Tier 1 Memory
 - Tier 1 Redstone Card or Redstone I/O block
 
Installing:
 1. Download this file as init.lua to hard drive in access computer system (pastebin get  init.lua)
 2. Boot from drive by Lua BIOS
 3. Make first Setup
 4. Enjoy))
 
To enter in Setup menu, click on 'c' in "(c)" in copyright line and enter access password

After entering correct password, player's "fingerprint" adds to DB
Player may be deleted from DB by removing his nickname from /configs/fingers.cfg
]]

function totable(inputstr)
  local t={}
   for str in string.gmatch(inputstr, "([^\n]+)") do
     table.insert(t, str)
   end
   return t
end

function untable(table)
  res= ''
  for _,x in pairs(table) do
    res= res..x..'\n'
  end
  return res
end

function sleep(timeout)
  checkArg(1, timeout, "number", "nil")
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    pull(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

function pull(...)
  local args = table.pack(...)
  if type(args[1]) == "string" then
    return pullFiltered(createPlainFilter(...))
  else
    checkArg(1, args[1], "number", "nil")
    checkArg(2, args[2], "string", "nil")
    return pullFiltered(args[1], createPlainFilter(select(2, ...)))
  end
end

function pullFiltered(...)
  local args = table.pack(...)
  local seconds, filter = math.huge

  if type(args[1]) == "function" then
    filter = args[1]
  else
    checkArg(1, args[1], "number", "nil")
    checkArg(2, args[2], "function", "nil")
    seconds = args[1]
    filter = args[2]
  end

  repeat
    local signal = table.pack(computer.pullSignal(seconds))
    if signal.n > 0 then
      if not (seconds or filter) or filter == nil or filter(table.unpack(signal, 1, signal.n)) then
        return table.unpack(signal, 1, signal.n)
      end
    end
  until signal.n == 0
end

function createPlainFilter(name, ...)
  local filter = table.pack(...)
  if name == nil and filter.n == 0 then
    return nil
  end

  return function(...)
    local signal = table.pack(...)
    if name and not (type(signal[1]) == "string" and signal[1]:match(name)) then
      return false
    end
    for i = 1, filter.n do
      if filter[i] ~= nil and filter[i] ~= signal[i + 1] then
        return false
      end
    end
    return true
  end
end

function drawplate(preset)
  if preset == 'gr' then
    vid.setBackground(1)
    vid.fill(1,1,60,5, " ")
    vid.setForeground(0)
    vid.set(8,1,'SecuCODEX Code Door System')
    npos = (40-10-#who)/2
    if (40-10-#who)%2 ~= 0 then npos = npos + 1 end
    vid.set(math.floor(npos)+1,3,'Welcome, '..who..'!')
  end
  if preset == 'wh' then
    vid.setBackground(1)
    vid.fill(1,1,60,5, " ")
    vid.setForeground(0)
    vid.set(8,1,'SecuCODEX Code Door System')
  end
  if preset == 'rd' then
    vid.setBackground(1)
    vid.fill(1,1,60,5, " ")
    vid.setForeground(0)
    vid.set(8,1,'SecuCODEX Code Door System')
    vid.set(14,3,'ACCESS DENIED!')
  end
end

function drawkeys()
  vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
  vid.set(3,7 , '╔═════╗  ╔═════╗  ╔═════╗')
  vid.set(3,8 , '║  1  ║  ║  2  ║  ║  3  ║')
  vid.set(3,9 , '╚═════╝  ╚═════╝  ╚═════╝')
  vid.set(3,10, '╔═════╗  ╔═════╗  ╔═════╗')
  vid.set(3,11, '║  4  ║  ║  5  ║  ║  6  ║')
  vid.set(3,12, '╚═════╝  ╚═════╝  ╚═════╝')
  vid.set(3,13, '╔═════╗  ╔═════╗  ╔═════╗')
  vid.set(3,14, '║  7  ║  ║  8  ║  ║  9  ║')
  vid.set(3,15, '╚═════╝  ╚═════╝  ╚═════╝')
  vid.set(3,16, '╔═════╗  ╔═════╗  ╔═════╗')
  vid.set(3,17, '║  C  ║  ║  0  ║  ║  E  ║')
  vid.set(3,18, '╚═════╝  ╚═════╝  ╚═════╝')
end

function drawfinger()
  vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
  vid.set(30,9 , '╔═════════╗')
  vid.set(30,10, '║Finger   ║')
  vid.set(30,11, '║   print ║')
  vid.set(30,12, '║ Scanner ║')
  vid.set(30,13, '║Compys   ║')
  vid.set(30,14, '║ OCFPS-35║')
  vid.set(30,15, '╚═════════╝')
end

function drawpushed(x,y,n)
  vid.setBackground(0xFF0000)
  vid.setForeground(0x000000)
  vid.set(x,y  , '╔═════╗')
  vid.set(x,y+1, '║  '..n..'  ║')
  vid.set(x,y+2, '╚═════╝')
end

function know(setmode)
  z = {{3,7},{4,7},{5,7},{6,7},{7,7},{8,7},{9,7},
       {3,8},{4,8},{5,8},{6,8},{7,8},{8,8},{9,8},
       {3,9},{4,9},{5,9},{6,9},{7,9},{8,9},{9,9}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 3,7,1 end
  end
  z = {{12,7},{13,7},{14,7},{15,7},{16,7},{17,7},{18,7},
       {12,8},{13,8},{14,8},{15,8},{16,8},{17,8},{18,8},
       {12,9},{13,9},{14,9},{15,9},{16,9},{17,9},{18,9}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 12,7,2 end
  end
  z = {{21,7},{22,7},{23,7},{24,7},{25,7},{26,7},{27,7},
       {21,8},{22,8},{23,8},{24,8},{25,8},{26,8},{27,8},
       {21,9},{22,9},{23,9},{24,9},{25,9},{26,9},{27,9}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 21,7,3 end
  end
  z = {{3,10},{4,10},{5,10},{6,10},{7,10},{8,10},{9,10},
       {3,11},{4,11},{5,11},{6,11},{7,11},{8,11},{9,11},
       {3,12},{4,12},{5,12},{6,12},{7,12},{8,12},{9,12}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 3,10,4 end
  end
  z = {{12,10},{13,10},{14,10},{15,10},{16,10},{17,10},{18,10},
       {12,11},{13,11},{14,11},{15,11},{16,11},{17,11},{18,11},
       {12,12},{13,12},{14,12},{15,12},{16,12},{17,12},{18,12}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 12,10,5 end
  end
  z = {{21,10},{22,10},{23,10},{24,10},{25,10},{26,10},{27,10},
       {21,11},{22,11},{23,11},{24,11},{25,11},{26,11},{27,11},
       {21,12},{22,12},{23,12},{24,12},{25,12},{26,12},{27,12}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 21,10,6 end
  end
  z = {{3,13},{4,13},{5,13},{6,13},{7,13},{8,13},{9,13},
       {3,14},{4,14},{5,14},{6,14},{7,14},{8,14},{9,14},
       {3,15},{4,15},{5,15},{6,15},{7,15},{8,15},{9,15}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 3,13,7 end
  end
  z = {{12,13},{13,13},{14,13},{15,13},{16,13},{17,13},{18,13},
       {12,14},{13,14},{14,14},{15,14},{16,14},{17,14},{18,14},
       {12,15},{13,15},{14,15},{15,15},{16,15},{17,15},{18,15}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 12,13,8 end
  end
  z = {{21,13},{22,13},{23,13},{24,13},{25,13},{26,13},{27,13},
       {21,14},{22,14},{23,14},{24,14},{25,14},{26,14},{27,14},
       {21,15},{22,15},{23,15},{24,15},{25,15},{26,15},{27,15}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 21,13,9 end
  end
  z = {{3,16},{4,16},{5,16},{6,16},{7,16},{8,16},{9,16},
       {3,17},{4,17},{5,17},{6,17},{7,17},{8,17},{9,17},
       {3,18},{4,18},{5,18},{6,18},{7,18},{8,18},{9,18}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 3,16,'C' end
  end
  z = {{12,16},{13,16},{14,16},{15,16},{16,16},{17,16},{18,16},
       {12,17},{13,17},{14,17},{15,17},{16,17},{17,17},{18,17},
       {12,18},{13,18},{14,18},{15,18},{16,18},{17,18},{18,18}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 12,16,0 end
  end
  z = {{21,16},{22,16},{23,16},{24,16},{25,16},{26,16},{27,16},
       {21,17},{22,17},{23,17},{24,17},{25,17},{26,17},{27,17},
       {21,18},{22,18},{23,18},{24,18},{25,18},{26,18},{27,18}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 21,16,'E' end
  end
  if tpoint[1] == 10 and tpoint[2] == 20 and setmode == false then setup() end
  if setmode == false then 
    z = {{30,9},{31,9},{32,9},{33,9},{34,9},{35,9},{36,9},{37,9},{38,9},{39,9},{40,9},
         {30,10},{31,10},{32,10},{33,10},{34,10},{35,10},{36,10},{37,10},{38,10},{39,10},{40,10},
         {30,11},{31,11},{32,11},{33,11},{34,11},{35,11},{36,11},{37,11},{38,11},{39,11},{40,11},
         {30,12},{31,12},{32,12},{33,12},{34,12},{35,12},{36,12},{37,12},{38,12},{39,12},{40,12},
         {30,13},{31,13},{32,13},{33,13},{34,13},{35,13},{36,13},{37,13},{38,13},{39,13},{40,13},
         {30,14},{31,14},{32,14},{33,14},{34,14},{35,14},{36,14},{37,14},{38,14},{39,14},{40,14},
         {30,15},{31,15},{32,15},{33,15},{34,15},{35,15},{36,15},{37,15},{38,15},{39,15},{40,15}}
    for _,point in pairs(z) do
      if tpoint[1] == point[1] and tpoint[2] == point[2] then
        fg=1
        finger()
        for _,name in pairs(allowed) do
          if who == name then inpassw = passw fg= nil return 500,500,'E' end
        end
      end
    end
    if fg == 1 then fg = 0 inpassw='' return 500,500,'E' end
  end
end 

function setup()
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,1,60,5, " ")
  vid.set(1,1,'SecuCODEX Mono Edition v1.09 Setup')
  vid.set(1,2,'Old Password: ')
  apassw = ''
  drawkeys()
  pos = 1
  while true do
    _,_,tx,ty,_,who = pull('touch')
    tpoint = {tx,ty}
    x,y,n = know(true)
    if n ~= nil then
      drawpushed(x,y,n)
      vid.setBackground(0x000000)
      vid.setForeground(0xFFFFFF)
      if n== 'C' then apassw='' vid.fill(14, 2, 60, 1, " ") pos =1 sleep(0.1) drawkeys()
      elseif n== 'E' then sleep(0.1) drawkeys() break
      else
        pos = pos+1
        apassw = apassw..n
        vid.set(pos+13,2, "*")
        sleep(0.1)
        drawkeys() 
      end
    end
  end
  if apassw == passw then intap() else drawplate('wh') end
end

function intap()
  f=hdd.open('/configs/sets.cfg',"w")
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,1,60,5, " ")
  vid.set(1,1,'SecuCODEX Mono Edition v1.09 Setup')
  vid.set(1,2,'New Password: ')
  passw = ''
  drawkeys()
  pos = 1
  while true do
    _,_,tx,ty,_,who = pull('touch')
    tpoint = {tx,ty}
    x,y,n = know(true)
    if n ~= nil then
      drawpushed(x,y,n)
      vid.setBackground(0x000000)
      vid.setForeground(0xFFFFFF)
      if n== 'C' then passw='' vid.fill(14, 2, 60, 1, " ") pos =1 sleep(0.1) drawkeys()
      elseif n== 'E' then sleep(0.1) drawkeys() break
      else
        pos = pos+1
        passw = passw..n
        vid.set(pos+13,2, "*")
        sleep(0.1)
        drawkeys() 
      end
    end
  end
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,2,60,5, " ")
  vid.set(1,2,'Side for correct code (0-5): ')
  corr = ''
  pos = 1
  while true do
    _,_,tx,ty,_,who = pull('touch')
    tpoint = {tx,ty}
    x,y,n = know(true)
    if n ~= nil then
      drawpushed(x,y,n)
      vid.setBackground(0x000000)
      vid.setForeground(0xFFFFFF)
      if n== 'C' then corr='' vid.fill(29, 2, 60, 1, " ") pos =1 sleep(0.1) drawkeys()
      elseif n== 'E' then sleep(0.1) drawkeys() break
      else
        pos = pos+1
        corr = corr..n
        vid.set(pos+28,2, tostring(n))
        sleep(0.1)
        drawkeys() 
      end
    end
  end
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,2,60,5, " ")
  vid.set(1,2,'Side for incorrect code (0-5): ')
  incorr = ''
  pos = 1
  while true do
    _,_,tx,ty,_,who = pull('touch')
    tpoint = {tx,ty}
    x,y,n = know(true)
    if n ~= nil then
      drawpushed(x,y,n)
      vid.setBackground(0x000000)
      vid.setForeground(0xFFFFFF)
      if n== 'C' then incorr='' vid.fill(31, 2, 60, 1, " ") pos =1 sleep(0.1) drawkeys()
      elseif n== 'E' then sleep(0.1) drawkeys() break
      else
        pos = pos+1
        incorr = incorr..n
        vid.set(pos+30,2, tostring(n))
        sleep(0.1)
        drawkeys() 
      end
    end
  end
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,2,60,5, " ")
  vid.set(1,2,'Show password? [E/C]: ')
  while true do
    _,_,tx,ty,_,who = pull('touch')
    tpoint = {tx,ty}
    x,y,n = know(true)
    if n ~= nil then
      drawpushed(x,y,n)
      if n== 'C' then stars = 'false' sleep(0.1) drawkeys() break
      elseif n== 'E' then stars = 'true' sleep(0.1) drawkeys() break
      end
    end
  end
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,2,60,5, " ")
  vid.set(1,2,'Show key push? [E/C]: ')
  while true do
    _,_,tx,ty,_,who = pull('touch')
    tpoint = {tx,ty}
    x,y,n = know()
    if n ~= nil then
      drawpushed(x,y,n)
      if n== 'C' then kpush = 'false'  sleep(0.1) drawkeys() break
      elseif n== 'E' then kpush = 'true' sleep(0.1) drawkeys() break 
      end
    end
  end
  hdd.write(f,passw..'\n'..stars..'\n'..kpush..'\n'..corr..'\n'..incorr)
  hdd.close(f)
  computer.shutdown(true)
end

function finger()
  vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
  rr=14
  while rr ~=10 do
    vid.set(31,rr, '─────────')
    sleep(0.05)
    vid.set(31,rr, '         ')
    rr=rr-1
  end
  while rr ~=14 do
    vid.set(31,rr, '─────────')
    sleep(0.05)
    vid.set(31,rr, '         ')
    rr=rr+1
  end
  sleep(0.05)
  vid.set(31,10, '█████████')
  vid.set(31,11, '█  ████ █')
  vid.set(31,12, '█ █ █ █ █')
  vid.set(31,13, '█ █ █ █ █')
  vid.set(31,14, '█████████')
end

if component.list("gpu")() == nil then error('Ow, where is Video Card?') end
vid=component.proxy(component.list("gpu")())
if vid.maxDepth() > 1 then error("It's version for Tier 1 Video Card only!") end
if component.list("redstone")() == nil then error('Redstone device not found in system!') end
red=component.proxy(component.list("redstone")())
mx, my = vid.getResolution()
vid.fill(1, 1, mx, my, " ")
vid.setResolution(40,20)
mx, my = vid.getResolution()
for hda in pairs(component.list("filesystem")) do 
  hdd=component.proxy(hda)
  if hdd.getLabel() ~= 'tmpfs' then break end
end
if hdd.exists('/configs/sets.cfg') then
  f=hdd.open('/configs/sets.cfg',"r")
  rd=hdd.read(f,512) 
  if rd == nil then intap() end
  rd = totable(rd)
  if #rd ~= 5 then intap() end
  passw= rd[1]
  stars= rd[2]
  kpush= rd[3] 
  corr= rd[4] 
  incorr= rd[5]
  hdd.close(f)
  f=hdd.open('/configs/fingers.cfg',"r")
  allowed = hdd.read(f,2048)
  if allowed == nil then allowed = {} else allowed = totable(allowed) end
  hdd.close(f)
else
  hdd.makeDirectory('/configs/')
  hdd.open('/configs/fingers.cfg',"w")
  intap()
end
drawplate('wh')
drawkeys()
vid.setForeground(0x00FF00)
vid.set(4,20,'2020 (c) Compys Security Software')
while true do
  inpassw=''
  see=''
  drawkeys()
  drawfinger()
  pos = 1
  prept = 21
  while true do
    _,_,tx,ty,_,who = pull('touch')
    tpoint = {tx,ty}
    x,y,n = know(false)
    if n ~= nil then
      if kpush =='true' then drawpushed(x,y,n) end
      vid.setBackground(0xFFFFFF)
      vid.setForeground(0x000000)
      if n== 'C' then inpassw='' see='' vid.fill(1, 3, 60, 1, " ") pos =1 prept = 31 sleep(0.1) drawkeys()
      elseif n== 'E' then sleep(0.1) drawkeys() break
      else
        pos = pos+1
        if pos % 2 == 0 then prept= prept-1 end
        inpassw = inpassw..n
        if stars == 'false' then
          see= see..'*'
        else
          see= see..n
        end
        vid.set(prept,3,see)
        sleep(0.1)
        drawkeys() 
      end
    end
  end
  if inpassw == passw then
    drawplate('gr')
    red.setOutput(tonumber(corr), 15)
    for _,name in pairs(allowed) do
      if who == name then exis=true break end
    end
    if exis~=true then table.insert(allowed, who) f=hdd.open('/configs/fingers.cfg',"w") hdd.write(f,untable(allowed)) hdd.close(f) end
    exis= nil
  else
    drawplate('rd')
    red.setOutput(tonumber(incorr), 15)
  end
  sleep(1.5)
  drawplate('wh')
  red.setOutput(tonumber(corr), 0)
  red.setOutput(tonumber(incorr), 0)
end
