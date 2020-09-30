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
 - Tier 1 Hard Drive
 - 1x Tier 1 Memory
 - Tier 1 Redstone Card or Redstone I/O block

Install Tier 3 Computer, Video Card and Monitor to set 256 color mode in program

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
end

function drawpushed(x,y,n)
  vid.setBackground(0xFF0000)
  vid.setForeground(0x000000)
  vid.set(x,y  , '╔═══════╗')
  vid.set(x,y+1, '║       ║')
  vid.set(x,y+2, '║   '..n..'   ║')
  vid.set(x,y+3, '║       ║')
  vid.set(x,y+4, '╚═══════╝')
end

function know(setmode)
  z = {{7,11},{8,11},{9,11},{10,11},{11,11},{12,11},{13,11},
       {7,12},{8,12},{9,12},{10,12},{11,12},{12,12},{13,12},
       {7,13},{8,13},{9,13},{10,13},{11,13},{12,13},{13,13}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 6,10,1 end
  end
  z = {{19,11},{20,11},{21,11},{22,11},{23,11},{24,11},{25,11},
       {19,12},{20,12},{21,12},{22,12},{23,12},{24,12},{25,12},
       {19,13},{20,13},{21,13},{22,13},{23,13},{24,13},{25,13}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 18,10,2 end
  end
  z = {{31,11},{32,11},{33,11},{34,11},{35,11},{36,11},{37,11},
       {31,12},{32,12},{33,12},{34,12},{35,12},{36,12},{37,12},
       {31,13},{32,13},{33,13},{34,13},{35,13},{36,13},{37,13}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 30,10,3 end
  end
  z = {{7,16},{8,16},{9,16},{10,16},{11,16},{12,16},{13,16},
       {7,17},{8,17},{9,17},{10,17},{11,17},{12,17},{13,17},
       {7,18},{8,18},{9,18},{10,18},{11,18},{12,18},{13,18}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 6,15,4 end
  end
  z = {{19,16},{20,16},{21,16},{22,16},{23,16},{24,16},{25,16},
       {19,17},{20,17},{21,17},{22,17},{23,17},{24,17},{25,17},
       {19,18},{20,18},{21,18},{22,18},{23,18},{24,18},{25,18}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 18,15,5 end
  end
  z = {{31,16},{32,16},{33,16},{34,16},{35,16},{36,16},{37,16},
       {31,17},{32,17},{33,17},{34,17},{35,17},{36,17},{37,17},
       {31,18},{32,18},{33,18},{34,18},{35,18},{36,18},{37,18}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 30,15,6 end
  end
  z = {{7,21},{8,21},{9,21},{10,21},{11,21},{12,21},{13,21},
       {7,22},{8,22},{9,22},{10,22},{11,22},{12,22},{13,22},
       {7,23},{8,23},{9,23},{10,23},{11,23},{12,23},{13,23}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 6,20,7 end
  end
  z = {{19,21},{20,21},{21,21},{22,21},{23,21},{24,21},{25,21},
       {19,22},{20,22},{21,22},{22,22},{23,22},{24,22},{25,22},
       {19,23},{20,23},{21,23},{22,23},{23,23},{24,23},{25,23}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 18,20,8 end
  end
  z = {{31,21},{32,21},{33,21},{34,21},{35,21},{36,21},{37,21},
       {31,22},{32,22},{33,22},{34,22},{35,22},{36,22},{37,22},
       {31,23},{32,23},{33,23},{34,23},{35,23},{36,23},{37,23}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 30,20,9 end
  end
  z = {{7,26},{8,26},{9,26},{10,26},{11,26},{12,26},{13,26},
       {7,27},{8,27},{9,27},{10,27},{11,27},{12,27},{13,27},
       {7,28},{8,28},{9,28},{10,28},{11,28},{12,28},{13,28}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 6,25,'C' end
  end
  z = {{19,26},{20,26},{21,26},{22,26},{23,26},{24,26},{25,26},
       {19,27},{20,27},{21,27},{22,27},{23,27},{24,27},{25,27},
       {19,28},{20,28},{21,28},{22,28},{23,28},{24,28},{25,28}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 18,25,0 end
  end
  z = {{31,26},{32,26},{33,26},{34,26},{35,26},{36,26},{37,26},
       {31,27},{32,27},{33,27},{34,27},{35,27},{36,27},{37,27},
       {31,28},{32,28},{33,28},{34,28},{35,28},{36,28},{37,28}}
  for _,point in pairs(z) do
    if tpoint[1] == point[1] and tpoint[2] == point[2] then return 30,25,'E' end
  end
  if tpoint[1] == 21 and tpoint[2] == 30 and setmode == false then setup() end
  if setmode == false then 
    z = {{44,17},{45,17},{46,17},{47,17},{48,17},{49,17},{50,17},{51,17},{52,17},{53,17},{54,17},{55,17},{56,17},
        {44,18},{45,18},{46,18},{47,18},{48,18},{49,18},{50,18},{51,18},{52,18},{53,18},{54,18},{55,18},{56,18},
        {44,19},{45,19},{46,19},{47,19},{48,19},{49,19},{50,19},{51,19},{52,19},{53,19},{54,19},{55,19},{56,19},
        {44,20},{45,20},{46,20},{47,20},{48,20},{49,20},{50,20},{51,20},{52,20},{53,20},{54,20},{55,20},{56,20},
        {44,21},{45,21},{46,21},{47,21},{48,21},{49,21},{50,21},{51,21},{52,21},{53,21},{54,21},{55,21},{56,21},
        {44,22},{45,22},{46,22},{47,22},{48,22},{49,22},{50,22},{51,22},{52,22},{53,22},{54,22},{55,22},{56,22}}
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
  vid.fill(1,1,60,9, " ")
  vid.set(1,1,'SecuCODEX Color Edition v1.09 Setup')
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
  vid.fill(1,1,60,9, " ")
  vid.set(1,1,'SecuCODEX Color Edition v1.09 Setup')
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
  vid.fill(1,2,60,8, " ")
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
  vid.fill(1,2,60,8, " ")
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
  vid.fill(1,2,60,8, " ")
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
  vid.fill(1,2,60,8, " ")
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
    _,_,tx,ty,_,who = pull('touch')
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
  sleep(1.5)
  drawplate('wh')
  red.setOutput(tonumber(corr), 0)
  red.setOutput(tonumber(incorr), 0)
end
