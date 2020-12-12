--[[ SecuCODEX Code Door System.
     Color Edition
Program-system for password and "fingerprint" based color access computer system
ONLY FOR TIER 2 OR TIER 3 VIDEO CARDS
Author: Bs()Dd

Idea and base interface concept borrowed from ECS's CodeDoor

Program-system working without OpenOS, because "hackers" can't kill it by CTRL+ALT+C

Minimal requirements to computer system:
 - Tier 2 Computer
 - Tier 2 Video Card
 - Tier 2 Monitor
 - Tier 1 Processor
 - Tier 1 Hard Drive or Floppy Disk
 - 1x Tier 1 Memory
 - Tier 1 Redstone Card or Redstone I/O block

Install Tier 3 Computer, Video Card and Monitor to set 256 color mode in program

Installing:
 1. Download this file as init.lua to hard drive or floppy disk in access computer system (pastebin get jJWDicaJ init.lua)
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
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

function drawplate(preset)
 if vid.maxDepth() == 4 then
   if preset == 'gr' then
    vid.setBackground(5, true)
    vid.fill(1,1,60,7, " ")
    vid.setForeground(15, true)
    vid.set(18,1,'SecuCODEX Code Door System')
    npos = (61-10-#who)/2
    if (61-10-#who)%2 ~= 0 then npos = npos + 1 end
    vid.set(math.floor(npos),4,'Welcome, '..who..'!')
    vid.setBackground(13, true)
    vid.fill(1,8,60,1, " ")
    vid.setBackground(7, true)
    vid.fill(1,9,60,1, " ")
  end
  if preset == 'wh' then
    vid.setBackground(0, true)
    vid.fill(1,1,60,7, " ")
    vid.setForeground(15, true)
    vid.set(18,1,'SecuCODEX Code Door System')
    vid.setBackground(8, true)
    vid.fill(1,8,60,1, " ")
    vid.setBackground(7, true)
    vid.fill(1,9,60,1, " ")
  end
  if preset == 'rd' then
    vid.setBackground(14, true)
    vid.fill(1,1,60,7, " ")
    vid.setForeground(15, true)
    vid.set(18,1,'SecuCODEX Code Door System')
    vid.set(23,4,'ACCESS DENIED!')
    vid.setBackground(12, true)
    vid.fill(1,8,60,1, " ")
    vid.setBackground(7, true)
    vid.fill(1,9,60,1, " ")
  end
 else
  if preset == 'gr' then
    vid.setBackground(0x00FF00)
    vid.fill(1,1,60,7, " ")
    vid.setForeground(0x000000)
    vid.set(18,1,'SecuCODEX Code Door System')
    npos = (61-10-#who)/2
    if (61-10-#who)%2 ~= 0 then npos = npos + 1 end
    vid.set(math.floor(npos),4,'Welcome, '..who..'!')
    vid.setBackground(0x009200)
    vid.fill(1,8,60,1, " ")
    vid.setBackground(0x006D00)
    vid.fill(1,9,60,1, " ")
  end
  if preset == 'wh' then
    vid.setBackground(0xFFFFFF)
    vid.fill(1,1,60,7, " ")
    vid.setForeground(0x000000)
    vid.set(18,1,'SecuCODEX Code Door System')
    vid.setBackground(0xC3C3C3)
    vid.fill(1,8,60,1, " ")
    vid.setBackground(0x969696)
    vid.fill(1,9,60,1, " ")
  end
  if preset == 'rd' then
    vid.setBackground(0xFF0000)
    vid.fill(1,1,60,7, " ")
    vid.setForeground(0x000000)
    vid.set(18,1,'SecuCODEX Code Door System')
    vid.set(23,4,'ACCESS DENIED!')
    vid.setBackground(0x990000)
    vid.fill(1,8,60,1, " ")
    vid.setBackground(0x660000)
    vid.fill(1,9,60,1, " ")
  end
 end
 vid.setBackground(0x000000)
 vid.setForeground(0xFFFFFF)
end

function drawkeys()
  vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
  vid.set(6,10, '╔═══════╗   ╔═══════╗   ╔═══════╗')
  vid.set(6,11, '║       ║   ║       ║   ║       ║')
  vid.set(6,12, '║   1   ║   ║   2   ║   ║   3   ║')
  vid.set(6,13, '║       ║   ║       ║   ║       ║')
  vid.set(6,14, '╚═══════╝   ╚═══════╝   ╚═══════╝')
  vid.set(6,15, '╔═══════╗   ╔═══════╗   ╔═══════╗')
  vid.set(6,16, '║       ║   ║       ║   ║       ║')
  vid.set(6,17, '║   4   ║   ║   5   ║   ║   6   ║')
  vid.set(6,18, '║       ║   ║       ║   ║       ║')
  vid.set(6,19, '╚═══════╝   ╚═══════╝   ╚═══════╝')
  vid.set(6,20, '╔═══════╗   ╔═══════╗   ╔═══════╗')
  vid.set(6,21, '║       ║   ║       ║   ║       ║')
  vid.set(6,22, '║   7   ║   ║   8   ║   ║   9   ║')
  vid.set(6,23, '║       ║   ║       ║   ║       ║')
  vid.set(6,24, '╚═══════╝   ╚═══════╝   ╚═══════╝')
  vid.set(6,25, '╔═══════╗   ╔═══════╗   ╔═══════╗')
  vid.set(6,26, '║       ║   ║       ║   ║       ║')
  vid.set(6,27, '║   C   ║   ║   0   ║   ║   E   ║')
  vid.set(6,28, '║       ║   ║       ║   ║       ║')
  vid.set(6,29, '╚═══════╝   ╚═══════╝   ╚═══════╝')
  vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
end

function drawfinger()
  vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
  vid.set(43,16, '╔═════════════╗')
  vid.set(43,17, '║ Finger      ║')
  vid.set(43,18, '║       print ║')
  vid.set(43,19, '║  Scanner    ║')
  vid.set(43,20, '║             ║')
  vid.set(43,21, '║ Compys      ║')
  vid.set(43,22, '║   OCFPS-412 ║')
  vid.set(43,23, '╚═════════════╝')
   vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
end

function drawpushed(x,y,n)
  vid.setBackground(0xFF0000)
  vid.setForeground(0x000000)
  vid.set(x,y  , '╔═══════╗')
  vid.set(x,y+1, '║       ║')
  vid.set(x,y+2, '║   '..n..'   ║')
  vid.set(x,y+3, '║       ║')
  vid.set(x,y+4, '╚═══════╝')
  vid.setBackground(0x000000)
  vid.setForeground(0xFF0000)
end

function know(setmode)
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
  elseif tpoint[1] == 21 and tpoint[2] == 30 and setmode == false then setup() 
  elseif setmode == false then 
      if 43 < tpoint[1] and tpoint[1] < 56 and 16 < tpoint[2] and tpoint[2] < 23 then
        finger()
        for _,name in pairs(allowed) do
          if who == name then inpassw = passw fg= nil return 500,500,'E' end
        end
        inpassw='' return 500,500,'E'
      end
  end
end 

function setup()
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,1,60,9, " ")
  vid.set(1,1,'SecuCODEX Color Edition v1.09 Setup')
  vid.setForeground(0xFF0000)
  vid.set(1,2,'Old Password: ')
  apassw = ''
  drawkeys()
  pos = 1
  while true do
    _,_,tx,ty,_,who = computer.pullSignal('touch')
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
  vid.setBackground(0x000000)
  vid.setForeground(0xFFFFFF)
  vid.fill(1,1,60,9, " ")
  vid.set(1,1,'SecuCODEX Color Edition v1.09 Setup')
  vid.setForeground(0xFF0000)
  vid.set(1,2,'New Password: ')
  passw = ''
  drawkeys()
  pos = 1
  while true do
    _,_,tx,ty,_,who = computer.pullSignal('touch')
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
  vid.fill(1,2,60,8, " ")
  vid.set(1,2,'Side for correct code (0-5): ')
  corr = ''
  pos = 1
  while true do
    _,_,tx,ty,_,who = computer.pullSignal('touch')
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
  vid.fill(1,2,60,8, " ")
  vid.set(1,2,'Side for incorrect code (0-5): ')
  incorr = ''
  pos = 1
  while true do
    _,_,tx,ty,_,who = computer.pullSignal('touch')
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
  vid.fill(1,2,60,8, " ")
  vid.set(1,2,'Show password? [E/C]: ')
  while true do
    _,_,tx,ty,_,who = computer.pullSignal('touch')
    tpoint = {tx,ty}
    x,y,n = know(true)
    if n ~= nil then
      drawpushed(x,y,n)
      if n== 'C' then stars = 'false' sleep(0.1) drawkeys() break
      elseif n== 'E' then stars = 'true' sleep(0.1) drawkeys() break
      end
    end
  end
  vid.fill(1,2,60,8, " ")
  vid.set(1,2,'Show key push? [E/C]: ')
  while true do
    _,_,tx,ty,_,who = computer.pullSignal('touch')
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
  rr=22
  while rr ~=17 do
    vid.set(44,rr, '─────────────')
    sleep(0.05)
    vid.set(44,rr, '             ')
    rr=rr-1
  end
  while rr ~=22 do
    vid.set(44,rr, '─────────────')
    sleep(0.05)
    vid.set(44,rr, '             ')
    rr=rr+1
  end
  sleep(0.05)
  vid.set(44,17, ' ███████████ ')
  vid.set(44,18, ' █   ████  █ ')
  vid.set(44,19, ' █  █   █  █ ')
  vid.set(44,20, ' █  █ █ ██ █ ')
  vid.set(44,21, ' █ ██ █ █  █ ')
  vid.set(44,22, ' ███████████ ')
end

if component.list("gpu")() == nil then error('Ow, where is Video Card?') end
vid=component.proxy(component.list("gpu")())
if vid.maxDepth() == 1 then error('Tier 1 Video Card is not supported!') end
if component.list("redstone")() == nil then error('Redstone device not found in system!') end
red=component.proxy(component.list("redstone")())
mx, my = vid.getResolution()
vid.fill(1, 1, mx, my, " ")
vid.setResolution(60,30)
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
vid.set(15,30,'2020 (c) Compys Security Software')
while true do
  inpassw=''
  see=''
  drawkeys()
  drawfinger()
  pos = 1
  prept = 31
  while true do
    _,_,tx,ty,_,who = computer.pullSignal('touch')
    tpoint = {tx,ty}
    x,y,n = know(false)
    if n ~= nil then
      if kpush =='true' then drawpushed(x,y,n) end
      vid.setBackground(0xFFFFFF)
      vid.setForeground(0x000000)
      if n== 'C' then inpassw='' see='' vid.fill(1, 4, 60, 1, " ") pos =1 prept = 31 sleep(0.1) drawkeys()
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
        vid.set(prept,4,see)
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
  sleep(1)
  drawplate('wh')
  red.setOutput(tonumber(corr), 0)
  red.setOutput(tonumber(incorr), 0)
end
