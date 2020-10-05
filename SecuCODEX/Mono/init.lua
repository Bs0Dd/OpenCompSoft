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
 - Tier 1 Hard Drive or Floppy Disk
 - 1x Tier 1 Memory
 - Tier 1 Redstone Card or Redstone I/O block
 
Installing:
 1. Download this file as init.lua to hard drive or floppy disk in access computer system (pastebin get ahbjHpvV init.lua)
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
  vid.setBackground(1)
  vid.fill(1,1,60,5, " ")
  vid.setForeground(0)
  if preset == 'gr' then
    vid.set(8,1,'SecuCODEX Code Door System')
    npos = (40-10-#who)/2
    if (40-10-#who)%2 ~= 0 then npos = npos + 1 end
    vid.set(math.floor(npos)+1,3,'Welcome, '..who..'!')
  end
  if preset == 'wh' then
    vid.set(8,1,'SecuCODEX Code Door System')
  end
  if preset == 'rd' then
    vid.set(8,1,'SecuCODEX Code Door System')
    vid.set(14,3,'ACCESS DENIED!')
  end
end

function drawkeys()
  vid.setBackground(0)
  vid.setForeground(1)
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
  vid.setBackground(0)
  vid.setForeground(1)
  vid.set(30,9 , '╔═════════╗')
  vid.set(30,10, '║Finger   ║')
  vid.set(30,11, '║   print ║')
  vid.set(30,12, '║ Scanner ║')
  vid.set(30,13, '║Compys   ║')
  vid.set(30,14, '║ OCFPS-35║')
  vid.set(30,15, '╚═════════╝')
  vid.setBackground(0)
  vid.setForeground(1)
end

function drawpushed(x,y,n)
  vid.setBackground(1)
  vid.setForeground(0)
  vid.set(x,y  , '╔═════╗')
  vid.set(x,y+1, '║  '..n..'  ║')
  vid.set(x,y+2, '╚═════╝')
end

function know(setmode)
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
  elseif tpoint[1] == 10 and tpoint[2] == 20 and setmode == false then setup() 
  elseif setmode == false then 
      if 29 < tpoint[1] and tpoint[1] < 41 and 8 < tpoint[2] and tpoint[2] < 16 then
        finger()
        for _,name in pairs(allowed) do
          if who == name then inpassw = passw fg= nil return 500,500,'E' end
        end
        inpassw='' return 500,500,'E'
      end
  end
end  

function setup()
  vid.setBackground(0)
  vid.setForeground(1)
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
  vid.setBackground(0)
  vid.setForeground(1)
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
  vid.setBackground(0)
  vid.setForeground(1)
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
      if n== 'C' then inpassw='' see='' vid.fill(1, 3, 60, 1, " ") pos =1 prept = 21 sleep(0.1) drawkeys()
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
