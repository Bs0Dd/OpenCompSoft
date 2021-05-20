--[[Compys(TM) TapFAT Tape Configuration Tool v1.01
	2021 (C) Compys S&N Systems
	This is a tool for do some manipulations with TapFAT tapes
	Please, load "tfatinit" driver firstly
]]
local comp = require('component')
local fs = require('filesystem')
local term = require('term')
local event = require('event')
local unicode = require('unicode')
local len = unicode.len
local sub = unicode.sub
local keys = require('keyboard').keys
local gpu = comp.gpu

local cx, cy = gpu.getResolution()

local function SetColor(cl)
  gpu.setForeground(cl[1])
  gpu.setBackground(cl[2])
end

local normcol
local menusel
local alarmcl
local red

if gpu.maxDepth() > 1 then
	normcol = {0xFFFFFF,0x0000FF}
	menusel = {0x000000,0xFFFF00}
	alarmcl = {0xFFFFFF,0xFF0000}
	red = 0xFF0000
else
	normcol = {0x000000,0xFFFFFF}
	menusel = {0xFFFFFF,0x000000}
	alarmcl = normcol
	red = 0x000000
end

local function Dialog(uv,Menu,cl,Lines,Str,But)
  SetColor(cl)
  local H
  if Menu then H=#But+2+#Lines else H=#Lines+3 end
  local CurBut=1
  if Str then H=H+1 CurBut=0 end
  if not But then But={"Ok"} end
  local function Buttons()
	if Menu then return '' end
    local Butt=''
    for i=1,#But do
      if i==CurBut then
        Butt=Butt..'['..But[i]..']'
      else
        Butt=Butt..' '..But[i]..' '
      end
    end
    return Butt
  end
  local W=len(Buttons())
  if Menu then
	for i=1,#But do
		if len(But[i])>W then W=len(But[i]) end
	end
  end
  for i=1,#Lines do
	if len(Lines[i])>W then W=len(Lines[i]) end
  end
  if Str and (len(Str)>W) then W=len(Str) end
  W=W+4
  local x= math.ceil((cx-W)/2)
  local y= math.ceil((cy-H)/2)+ math.ceil(cy/10)
  gpu.set(x-1, y, ' ╔'..string.rep('═',W-2)..'╗ ')
  local dept = gpu.getDepth()
  local dlgLen = W+2
  local Strs
  if Menu then Strs=#But+#Lines else Strs=#Lines+2 end
  for i=1,Strs do
    gpu.set(x-1, y+i, ' ║'..string.rep(' ',W-2)..'║ ') 
    local sym = gpu.get(x-1+dlgLen, y+i)
    local sym2 = gpu.get(x+dlgLen, y+i)
	if sym == '▒' then sym = ' ' end
	if sym2 == '▒' then sym2 = ' ' end
    SetColor({0xCCCCCC, 0x000000})
    gpu.set(x-1+dlgLen, y+i, sym)
    gpu.set(x+dlgLen, y+i, sym2)
    SetColor(cl)
  end
  gpu.set(x-1, y+H-1,' ╚'..string.rep('═',W-2)..'╝ ')
  local sym = gpu.get(x-1+dlgLen, y+H-1)
  local sym2 = gpu.get(x+dlgLen, y+H-1)
  if sym == '▒' then sym = ' ' end
  if sym2 == '▒' then sym2 = ' ' end
  SetColor({0xCCCCCC, 0x000000})
  gpu.set(x-1+dlgLen, y+H-1, sym)
  gpu.set(x+dlgLen, y+H-1, sym2)
  for i=1, dlgLen do
    local sym = gpu.get(x+i,y+H)
    if sym == '▒' then sym = ' ' end
    gpu.set(x+i,y+H, sym)
  end
  SetColor(cl)
  if Menu then gpu.setForeground(red) end
  for i=1,#Lines do
    if Lines.left then gpu.set(x+2, y+i, Lines[i])
    else gpu.set(x+(W-len(Lines[i]))/2, y+i, Lines[i]) end
  end
  SetColor(cl)
  local mButtons = {}
  local Butt=''
  if not Menu then
	local ButtX = math.floor(x+(W-len(Buttons()))/2)
	for i=1,#But do
		table.insert(mButtons, {len(Butt)+ButtX-1, len(Butt..But[i])+ButtX+2, But[i]})
		Butt=Butt..' '..But[i]..' '
	end
  else
	mnuX = {dlgLen, dlgLen}
  end
  while not uv do
	if Menu then
		for i=1,#But do 
		  if i == CurBut then 
			SetColor(menusel)
			gpu.set(x+(W-len(But[i]))/2, y+i+#Lines, But[i])
			SetColor(cl)
		  else
			gpu.set(x+(W-len(But[i]))/2, y+i+#Lines, But[i])
		  end
		end
	else
		term.setCursor(x+(W-len(Buttons()))/2, y+H-2)
		term.write(Buttons())
	end
    if CurBut==0 then
      SetColor({0xFFFFFF, 0x333333})
      local S=Str
      if len(S)>W-4 then S='..'..sub(S,-W+6) end
      gpu.set(x+2, y+H-3, string.rep(' ',W-4))
      term.setCursor(x+2, y+H-3) term.write(S)
      if term.getCursor() > x+W-3 then term.setCursor(x+W-3, y+H-3) end
      SetColor(cl)
    end
    local evt
    if CurBut==0 then evt = term
    else evt = event end
    local eventname, _, ch, code = evt.pull()
    if eventname == 'key_down' then
      if code == keys.enter then
        if CurBut==0 then CurBut=1 end
        return But[CurBut],Str
	  elseif code == keys.up and CurBut~=0 and Menu then
		if CurBut>1 then CurBut=CurBut-1 end
	  elseif code == keys.down and CurBut~=0 and Menu then
		if CurBut<#But then CurBut=CurBut+1 end
      elseif code == keys.left and CurBut~=0 and not Menu then
        if CurBut>1 then CurBut=CurBut-1 end
      elseif code == keys.right and CurBut~=0 and not Menu then
        if CurBut<#But then CurBut=CurBut+1 end
      elseif code == keys.tab then
        if CurBut<#But then CurBut=CurBut+1
        else CurBut=Str and 0 or 1
        end
      elseif code == keys.back and CurBut==0 then
        if #Str>0 then gpu.set(x+1, y+H-3, string.rep(' ',W-2)) Str=sub(Str,1,-2) end
      elseif ch > 0 and CurBut == 0 then
        Str = Str..unicode.char(ch)
      end
    elseif eventname == 'clipboard' then
      if CurBut == 0 then
        Str = Str..ch
      end
    elseif eventname == 'touch' then
	  if Menu then
		if ch >= x+2 and ch <= x+W-3 then
			local cly = code-y-#Lines
			if cly > 0 and cly <= #But then 
				gpu.set(x+(W-len(But[CurBut]))/2, y+CurBut+#Lines, But[CurBut])
				SetColor(menusel)
				gpu.set(x+(W-len(But[cly]))/2, y+cly+#Lines, But[cly])
				SetColor(cl)
				os.sleep(0.05)
				return But[cly],Str
			end
		end
	  else
		if code == y+H-2 then
			for i=1, #mButtons do
			if ch>mButtons[i][1] and ch<mButtons[i][2] then
				return mButtons[i][3],Str
			end
			end
		elseif code == y+H-3 and Str then
			if ch>x+1 and ch<x+dlgLen-4 then CurBut=0 end
		end
	  end
    end
  end
end

local function selTap(list)
	local adrlist = {}
	for i = 1, #list do
		table.insert(adrlist, i..'. '..list[i][1].address)
	end
	table.insert(adrlist, 'Back')
	local sl = Dialog(false, true, normcol, {'Select drive:'}, nil, adrlist)
	if sl == 'Back' then return {-1} 
	else return list[tonumber(sl:sub(1,1))] end
end

local function drawBack()
	SetColor({0xCCCCCC,0x000000})
	gpu.fill(1,1,cx,cy,'▒')
	SetColor(normcol)
	local x = math.ceil((cx-42)/2)
	local posx = math.ceil((cx+42)/2)
	local y = math.ceil(cy/10)
	gpu.set(x, y  , ' ╔══════════════════════════════════════╗ ')
	gpu.set(x, y+1, ' ║ TapFAT Tape Configuration Tool v1.01 ║ ')
	gpu.set(x, y+2, ' ║      2021  © Compys S&N Systems      ║ ')
	gpu.set(x, y+3, ' ╚══════════════════════════════════════╝ ')
	if gpu.maxDepth() > 1 then
		gpu.setForeground(0xFFFF00)
		gpu.set(x+3, y+1, 'TapFAT')
	end
	gpu.setBackground(0x000000)
	gpu.set(posx, y+1, '  ')
	gpu.set(posx, y+2, '  ')
	gpu.set(posx, y+3, '  ')
	gpu.set(x+2, y+4, string.rep(' ', 42))
end

drawBack()
local tapes
local work = true

local function upList(after)
  tapes = {}
  for fsys, path in fs.mounts() do
	  if fsys.address:sub(-4) == '-tap' then table.insert(tapes, {fsys, path}) end
  end
  if #tapes == 0 then
	  drawBack()
	  if after then
		Dialog(false, false, alarmcl, {'No TapFAT drives found!', 'You have unmounted all drives.', 'Therefore, further work is impossible.'}, nil)
	  else
		Dialog(false, false, alarmcl, {'No TapFAT drives found!', 'Please check if the driver is loaded', 'or streamers is connected!'}, nil)
	  end 
	  work = false
  end
end

local function formatSize(size)
  local sizes = {"b", "Kb", "Mb", "Gb"}
  local unit = 1
  while size > 1024 and unit < #sizes do
    unit = unit + 1
    size = size / 1024
  end
  return math.floor(size * 10) / 10 .. sizes[unit]
end

upList(false)
while work do
	local whatdo = Dialog(false, true, normcol, {}, nil, {'Tapes information', 'Drives settings', 'Unmount drive', 'Format tape', 'Set label', 'Exit'})
	if whatdo == 'Exit' then
		work = false
	elseif whatdo == 'Drives settings' then
		local workwith
		if #tapes > 1 then
			workwith = selTap(tapes)[1]
		else
			workwith = tapes[1][1]
		end
		if workwith ~= -1 then
			while true do
				drawBack()
				tabcom = workwith.getDriveProperty('tabcom') == 1 and 'LZSS' or workwith.getDriveProperty('tabcom') == 2 and 'Data card' or 'No'
				stordate = workwith.getDriveProperty('stordate') and 'Yes' or 'No'
				local action = Dialog(false, true, normcol, {}, nil, {'Table compression: '..tabcom, 'Store file date: '..stordate, 'Back'})
				if action == 'Table compression: '..tabcom then
					local stat = Dialog(false, false, normcol, {'Do you want to use table compression?', ''}, nil, {'LZSS', 'Data card', 'No'})
					if stat == 'LZSS' then
						workwith.setDriveProperty('tabcom', 1)
					elseif stat == 'Data card' then
						workwith.setDriveProperty('tabcom', 2)
					else
						workwith.setDriveProperty('tabcom', false)
					end
				elseif action == 'Store file date: '..stordate then
					local stat = Dialog(false, false, normcol, {'Do you want to store file date?', ''}, nil, {'Yes', 'No'})
					if stat == 'Yes' then
						workwith.setDriveProperty('stordate', true)
					else
						workwith.setDriveProperty('stordate', false)
					end
				elseif action == 'Back' then break
				end
			end
		end
	elseif whatdo == 'Unmount drive' then
		local workwith
		if #tapes > 1 then
			workwith = selTap(tapes)[1]
		else
			workwith = tapes[1][1]
		end
		if workwith ~= -1 then 
			local ok = Dialog(false, false, normcol, {'Do you want to unmount tape drive?'}, nil, {'Unmount', 'Cancel'})
			if ok == 'Unmount' then
			  fs.umount(workwith)
			  upList(true)
			end
		end
	elseif whatdo == 'Tapes information' then
		local workwith, mnt
		if #tapes > 1 then
			local dat = selTap(tapes)
			workwith = dat[1]
			mnt = dat[2]
		else
			workwith = tapes[1][1]
			mnt = tapes[1][2]
		end
		if workwith ~= -1 then 
		  if not workwith.isReady() then 
			  Dialog(false, false, alarmcl, {'Device is not ready!', 'Please check if tape is loaded in streamer', 'and try again!'}, nil)
		  else
			  if not pcall(workwith.getTable) then
			    Dialog(false, false, alarmcl, {'Tape unformatted or FAT is corrupted!', 'Please use "Quick format" to remake table.'}, nil)
			  else
			    local info = {left = true}
			    info[1] = 'Label: '..(workwith.getLabel() == '' and '<No Label>' or workwith.getLabel())
			    info[2] = 'Tape type: '..math.ceil((workwith.spaceTotal()+8192)/245760)..' Min'
			    info[3] = 'Effective size: '..formatSize(workwith.spaceTotal())
			    info[4] = 'Free: '..formatSize(workwith.spaceTotal()-workwith.spaceUsed())..' ('..100-math.ceil((workwith.spaceUsed()/workwith.spaceTotal() * 100))..'%)'
			    info[5] = 'Mounted to: '..mnt
			    info[6] = ''
			    Dialog(false, false, normcol, info, nil)
			  end
		  end
		end
	elseif whatdo == 'Set label' then
		local workwith
		if #tapes > 1 then
			workwith = selTap(tapes)[1]
		else
			workwith = tapes[1][1]
		end
		if workwith ~= -1 then 
		  if not workwith.isReady() then 
			  Dialog(false, false, alarmcl, {'Device is not ready!', 'Please check if tape is loaded in streamer', 'and try again!'}, nil)
		  else 
			  local ok, labl = Dialog(false, false, normcol, {'Set a new label for tape:'}, workwith.getLabel(), {'Set', 'Cancel'})
			  if ok == 'Set' then
			  	workwith.setLabel(labl)
			  end
		  end
		end
	elseif whatdo == 'Format tape' then
		local workwith
		if #tapes > 1 then
			workwith = selTap(tapes)[1]
		else
			workwith = tapes[1][1]
		end
		if workwith ~= -1 then 
		  if not workwith.isReady() then 
			  Dialog(false, false, alarmcl, {'Device is not ready!', 'Please check if tape is loaded in streamer', 'and try again!'}, nil)
		  else
			  local mode = Dialog(false, true, normcol, {'Formatting mode:'}, nil, {'Quick format (Only FAT)','Full format (May take a long time)','Back'})
			  if mode == 'Quick format (Only FAT)' then
			    local ok = Dialog(false, false, alarmcl, {'WARNING!!!', 'File allocation table on the tape will be LOST.', 'Do you want to continue formatting?'}, nil, {'FORMAT', 'Cancel'})
			    if ok == 'FORMAT' then
				    drawBack()
				    Dialog(true, false, alarmcl, {'Formatting tape...', 'Please do not remove the tape', ' before the end of the process!'}, nil)
				    workwith.format(true)
			    end
			  elseif mode == 'Full format (May take a long time)' then
			    local ok = Dialog(false, false, alarmcl, {'WARNING!!!', 'All data on the tape will be LOST.', 'Do you want to continue formatting?'}, nil, {'FORMAT', 'Cancel'})
			    if ok == 'FORMAT' then
				    drawBack()
				    Dialog(true, false, alarmcl, {'Formatting tape...', 'Please do not remove the tape', ' before the end of the process!'}, nil)
				    workwith.format()
			    end
			  end
		  end
		end
	end
	drawBack()
end	

SetColor({0xFFFFFF,0x000000})
term.clear()