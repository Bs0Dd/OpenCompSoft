local gVER = "v1.01"

local engine = require("NyaDraw")
local component = require("component")
local unicode = require("unicode")
local fs = require('filesystem')
local srz = require("serialization")
local term = require("term")
local event = require("event")
local shell = require("shell")

local ulen = unicode.len
local pull = event.pull

local gpu = component.gpu
if gpu.maxDepth() < 8 then
	io.stderr:write("Error: Your graphics card or monitor doesn't support 256 colors\n")
	return
end
gpu.setResolution(160, 50)
gpu.setDepth(8)

term.clear()

local flist = fs.list(shell.getWorkingDirectory()..'/Languages')

local llist = {}
for f in flist do
	local fc = f:gmatch("[^.]+")
	local name, ext = fc(), fc()
	if ext:lower() == 'lng' then table.insert(llist, name) end
end
if #llist == 0 then
	io.stderr:write("Error: Can't find language files")
	return
end

print("Select language:")
print("------------------------------")
for i=1,#llist,1 do
	print(i..'.   '..llist[i])
end
print()

local v 
while true do
	io.write('>> ')
	v = io.read()
	if not v then return end
	v = tonumber(v)
	if v and llist[v] then break end
end

local locfil = io.open("Languages/"..llist[v]..".lng")
if not locfil then
	io.stderr:write("Error: Can't open language file\n")
	return
end
local locale, why = srz.unserialize(locfil:read("*a"))
locfil:close()
if not locale then
	io.stderr:write("Error: Can't load language file: "..(why or "unknown reason").."\n")
	return
end
local tmissing = "NOTEXT"

engine.setGPUProxy(gpu)
engine.update(true)

local gamelogo = engine.loadImage("Pictures/vvprom.pic")
local bcontrp = engine.loadImage("Pictures/bcontr.pic")
local editrp = engine.loadImage("Pictures/editor.pic")
local taskp = engine.loadImage("Pictures/task.pic")
local cidlogo = engine.loadImage("Pictures/cidlogo.pic")
local comlogo = engine.loadImage("Pictures/comlogo.pic")
local infoic = engine.loadImage("Pictures/info.pic")
local helpic = engine.loadImage("Pictures/help.pic")
local exitic = engine.loadImage("Pictures/exit.pic")

local vyzhCur
local frOp, frRun = true, true
local taskNum, tsk = 1
local x, y, a, b
local carry, curOp
local sOpX, sOpY, drawFrom = 1, 1, 1
local plotX, plotY, plotW
local totalInst = 0
local cmdCur = {
	{'INT', 42, ''},
	{'MOV', 'X', 0},
	{'MOV', 'Y', 0},
	{'INT', 44, ''},
	{'INT', 43, ''},
	{'MOV', 'X', 15},
	{'MOV', 'Y', 15},
	{'INT', 44, ''}
}

local function msgBox(contls, btok, tabl, hlt)
	btok = '  '..btok..'  '
	local W=ulen(btok)
	if tabl and 34 > ulen(btok) then W=34 end
	for i=1,#contls do
		if ulen(contls[i])>W then W=ulen(contls[i]) end
	end
	W = W+4
	local H=4+#contls
	if tabl then H= H+17 end
	local x= math.ceil((160-W)/2)
	local y= math.ceil((50-H)/2)
	engine.drawRectangle(x+2, y+1, W, H, 0x000000, 0x000000, ' ', 0.5)
	engine.drawRectangle(x, y, W, H, 0x0000FF, 0x000000, ' ')
	engine.drawText(x, y, 0xFFFFFF, '╔'..string.rep('═',W-2)..'╗')
	for i=1,H-2 do
		engine.drawText(x, y+i, 0xFFFFFF, '║'..string.rep(' ',W-2)..'║') 
	end
	engine.drawText(x, y+H-1, 0xFFFFFF, '╚'..string.rep('═',W-2)..'╝')
	for i=1,#contls do
		local xcor = math.ceil(W/2-ulen(contls[i])/2)
		if hlt and i==3 then
			engine.drawText(x+xcor, y+i, 0x00FF00, contls[i]) 
		else
			engine.drawText(x+xcor, y+i, 0xFFFFFF, contls[i]) 
		end
	end
	if tabl then
		local k = 1
		local tcor = math.ceil(W/2-16)-1
		for i=1, 32, 2 do
			for j=1, 32, 1 do
				engine.set(j+x+tcor, k+y+#contls+1, tabl[i][j] == 1 and 0x00FF00 or 0x1E1E1E, tabl[i+1][j] == 1 and 0x00FF00 or 0x1E1E1E, "▄")
			end
			k = k + 1
		end
	end
	local bcor = math.ceil(W/2-ulen(btok)/2)
	engine.drawRectangle(x+bcor, y+H-2, ulen(btok), 1, 0xFFFFFF, 0xFFFFFF, ' ')
	engine.drawText(x+bcor, y+H-2, 0x3C3C3C, btok)
	engine.update()
	while true do
		local typ, _, touch, key = pull()
		if typ == "key_down" then
			if key == 28 then return end
		elseif typ == "touch" then
			if touch >= x+bcor and touch <= x+bcor+ulen(btok)-1 and key == y+H-2 then return end
		end
	end
end

local function about()
	msgBox(locale.aboutText or {tmissing}, locale.close or tmissing)
end

local function help()
	msgBox(locale.helpText or {tmissing}, locale.close or tmissing)
end

local function qHelp()
	engine.drawRectangle(11, 6, 56, 40, 0x0F0F0F, 0x0F0F0F, ' ')
	engine.drawText(34, 6, 0x00FF00, "QUICK HELP")
	engine.drawText(29, 8, 0x00FF00, "AVAILABLE REGISTERS:")
	engine.drawText(34, 10, 0x00FF00, "A, B, X, Y")
	engine.drawText(28, 13, 0x00FF00, "AVAILABLE INSTRUCTIONS:")
	engine.drawText(11, 15, 0x00FF00, "INT <NUM OR REG> - BURNER INTERRUPTIONS")
	engine.drawText(16, 16, 0x00FF00, "42 - ENABLE BURNING")
	engine.drawText(16, 17, 0x00FF00, "43 - DISABLE BURNING")
	engine.drawText(16, 18, 0x00FF00, "44 - MOVE BURNER TO COORDINATES FROM X & Y REGS")
	engine.drawText(11, 20, 0x00FF00, "MOV <REG> <NUM OR REG> - MOVE <NUM OR REG> TO <REG>")
	engine.drawText(11, 22, 0x00FF00, "ADD <REG> <NUM OR REG> - ADD <NUM OR REG> TO <REG>")
	engine.drawText(11, 24, 0x00FF00, "MUL <REG> <NUM OR REG> - MULTIPLE <NUM OR REG> AND <REG>")
	engine.drawText(11, 26, 0x00FF00, "JMP <NUM OR REG> - JUMP OVER <NUM OR REG> LINES")
	engine.drawText(11, 28, 0x00FF00, "CMP <REG> <NUM OR REG> - COMPARE <REG> AND <NUM OR REG>")
	engine.drawText(11, 30, 0x00FF00, "J* <NUM OR REG> - JUMP OVER <NUM OR REG> LINES IF:")
	engine.drawText(16, 31, 0x00FF00, "JL - CMP RETURNED: LESS")
	engine.drawText(16, 32, 0x00FF00, "JE - CMP RETURNED: EQUAL")
	engine.drawText(16, 33, 0x00FF00, "JG - CMP RETURNED: GREATER")
	engine.update()
	while true do
		local typ, _, touch, key = pull()
		if typ == "key_down" then
			if key == 16 then return true
			elseif key == 35 then return false
			end
		elseif typ == "touch" then
			if touch >= 149 and touch <= 158 and key >= 5 and key <= 10 then return true
			elseif touch >= 82 and touch <= 90 and key >= 42 and key <= 44 then
				return false
			end
		end
	end
end

local function loadTsk()
	local rawf, why = io.open('Tasks/task'..taskNum..'.vtf')
	if not rawf then
		if taskNum == 1 then
		gpu.setForeground(0xFFFFFF)
		gpu.setBackground(0x000000)
		term.clear()
		io.stderr:write("Error: Can't open first task file: "..(why or "unknown reason").."\n")
		os.exit()
		else
			return false
		end
	end
	tsk, why = srz.unserialize(rawf:read("*a"))
	if not tsk then
		gpu.setForeground(0xFFFFFF)
		gpu.setBackground(0x000000)
		term.clear()
		io.stderr:write("Error: Can't load task file: "..(why or "unknown reason").."\n")
		os.exit()
	end
	taskNum = taskNum+1
	return true
end

local function vClean()
	vyzhCur = {
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	}
end

local function pattEq()
	for i=1, 32, 1 do
		for j=1, 32, 1 do
			if vyzhCur[i][j] ~= tsk[i][j] then return false end
		end
	end
	return true
end

local function drawMenu()
	engine.drawRectangle(1, 1, 160, 50, 0xA5A5A5, 0xA5A5A5, " ")
	engine.drawRectangle(1, 1, 160, 6, 0xFFFFFF, 0xFFFFFF, " ")
	engine.drawRectangle(1, 45, 160, 6, 0xFFFFFF, 0xFFFFFF, " ")
	engine.drawImage(4, 2, infoic)
	engine.drawImage(150, 2, helpic)
	engine.drawImage(150, 46, exitic)
end

local function drawSmBut(x, y, text)
	engine.drawSemiPixelRectangle(x, y, 9, 4, 0x00B6FF)
	engine.set(x,math.ceil(y/2), 0x0F0F0F, 0x00B6FF, "⢀")
	engine.set(x+8,math.ceil(y/2), 0x0F0F0F, 0x00B6FF, "⡀")
	engine.set(x,math.ceil(y/2)+2, 0x0F0F0F, 0x00B6FF, "⠈")
	engine.set(x+8,math.ceil(y/2)+2, 0x0F0F0F, 0x00B6FF, "⠁")
	engine.drawText(x+5-math.ceil(ulen(text)/2), math.ceil(y/2)+1, 0x000000, text)
end

local function drawBgBut(x, y, text)
	engine.drawSemiPixelRectangle(x, y, 24, 6, 0xCC2400)
	engine.set(x,math.ceil(y/2), 0x0F0F0F, 0xCC2400, "⣴")
	engine.set(x+23,math.ceil(y/2), 0x0F0F0F, 0xCC2400, "⣦")
	engine.set(x,math.ceil(y/2)+2, 0x0F0F0F, 0xCC2400, "⠻")
	engine.set(x+23,math.ceil(y/2)+2, 0x0F0F0F, 0xCC2400, "⠟")
	engine.drawText(x+12-math.ceil(ulen(text)/2), math.ceil(y/2)+1, 0xFFFFFF, text)
end

local function drawCmdBut()
	drawSmBut(82, 66, "MOV")
	drawSmBut(94, 66, "ADD")
	drawSmBut(106, 66, "MUL")
	drawSmBut(82, 72, "CMP")
	drawSmBut(94, 72, "J >")
	drawSmBut(106, 72, "J =")
	drawSmBut(118, 72, "J <")
	drawSmBut(130, 72, "JMP")
	drawSmBut(82, 78, "▲⠘⡟")
	drawSmBut(94, 78, "▼⠘⡟")
	drawSmBut(106, 78, "▶⠘⡟")
end

local function drawNumBut()
	drawSmBut(82, 66, "1")
	drawSmBut(94, 66, "2")
	drawSmBut(106, 66, "3")
	drawSmBut(118, 66, "X")
	drawSmBut(130, 66, "Y")
	drawSmBut(82, 72, "4")
	drawSmBut(94, 72, "5")
	drawSmBut(106, 72, "6")
	drawSmBut(118, 72, "A")
	drawSmBut(130, 72, "B")
	drawSmBut(82, 78, "7")
	drawSmBut(94, 78, "8")
	drawSmBut(106, 78, "9")
	drawSmBut(118, 78, "0")
	drawSmBut(130, 78, "-")
end

local function drawEdit(btext, isexec, iserr)
	local curfg = iserr and 0xFF0000 or 0x00FF00
	engine.drawRectangle(11, 6, 56, 40, 0x0F0F0F, 0x0F0F0F, ' ')
	engine.drawRectangle(82, 33, 57, 12, 0x0F0F0F, 0x0F0F0F, ' ')
	local pos = 6
	for i=drawFrom,39+drawFrom,1 do
		local cmd = cmdCur[i]
		if not cmd then break end
		engine.drawText(12, pos, 0x00FF00, cmd[1]..(" "):rep(6-#tostring(cmd[1]))..(cmd[2])..(" "):rep(6-#tostring(cmd[2]))..cmd[3])
		pos = pos + 1
	end
	engine.set(5+sOpX*6, sOpY+6-drawFrom, 0x0F0F0F, curfg, '[')
	if isexec then
		engine.drawLine(80, 27, 141, 27, 0x0F0F0F, 0x0F0F0F, ' ')
		engine.set(28, sOpY+6-drawFrom, 0x0F0F0F, curfg, ']')
	else
		engine.set(10+sOpX*6, sOpY+6-drawFrom, 0x0F0F0F, curfg, ']')
		if sOpX == 1 then
			drawCmdBut()
		else
			drawNumBut()
		end
		drawSmBut(82, 84, "?")
	end
	drawBgBut(117, 87, btext or tmissing)
	engine.update()
end

local function drawTab()
	local k = 1
	for i=1, 32, 2 do
		for j=1, 32, 1 do
			engine.set(j+94, k+8, vyzhCur[i][j] == 1 and 0x00FF00 or 0x1E1E1E, vyzhCur[i+1][j] == 1 and 0x00FF00 or 0x1E1E1E, "▄")
		end
		k = k + 1
	end
end

local function execute()
	x, y, a, b = 0, 0, 0, 0
	carry, curOp, sOpX, sOpY, drawFrom = 1, 1, 1, 0, 1
	plotX, plotY, plotW = 0, 0, false
	vClean()
	drawTab()
	engine.update()
	local i = 1
	while i<=#cmdCur do
		if cmdCur[i][1] == '' and cmdCur[i][2] == '' and cmdCur[i][3] == ''
			and #cmdCur > 1 then table.remove(cmdCur, i) i = i > 1 and i-1 or 0 end
		i = i + 1
	end
	i = 1
	while i<=#cmdCur do
		if cmdCur[i][1] == '' then
			sOpX = 1
			sOpY = i
			drawEdit(locale.exec, false, true)
			engine.drawText(12, 44, 0x00FF00, "ERROR")
			engine.drawText(12, 45, 0x00FF00, "UNSUPPORTED INSTRUCTION")
			engine.update()
			return nil, true
		elseif cmdCur[i][2] == '' then
			sOpX = 2
			sOpY = i
			drawEdit(locale.exec, false, true)
			engine.drawText(12, 44, 0x00FF00, "ERROR")
			engine.drawText(12, 45, 0x00FF00, "INVALID OPERAND")
			engine.update()
			return nil, true
		elseif cmdCur[i][2]== '-' or 
				(type(cmdCur[i][2]) == 'number' and (cmdCur[i][1] == "MOV" or cmdCur[i][1] == "ADD" or 
				cmdCur[i][1] == "MUL" or cmdCur[i][1] == "CMP")) then
			sOpX = 2
			sOpY = i
			drawEdit(locale.exec, false, true)
			engine.drawText(12, 44, 0x00FF00, "ERROR")
			engine.drawText(12, 45, 0x00FF00, "INVALID OPERAND TYPE")
			engine.update()
			return nil, true
		elseif cmdCur[i][3] == '' and (cmdCur[i][1] == "MOV" or cmdCur[i][1] == "ADD" or 
				cmdCur[i][1] == "MUL" or cmdCur[i][1] == "CMP") then
			sOpX = 3
			sOpY = i
			drawEdit(locale.exec, false, true)
			engine.drawText(12, 44, 0x00FF00, "ERROR")
			engine.drawText(12, 45, 0x00FF00, "INVALID OPERAND")
			engine.update()
			return nil, true
		elseif cmdCur[i][3]== '-' then
			sOpX = 3
			sOpY = i
			drawEdit(locale.exec, false, true)
			engine.drawText(12, 44, 0x00FF00, "ERROR")
			engine.drawText(12, 45, 0x00FF00, "INVALID OPERAND TYPE")
			engine.update()
			return nil, true
		elseif cmdCur[i][3] ~= '' and not (cmdCur[i][1] == "MOV" or cmdCur[i][1] == "ADD" or 
				cmdCur[i][1] == "MUL" or cmdCur[i][1] == "CMP") then
			sOpX = 3
			sOpY = i
			drawEdit(locale.exec, false, true)
			engine.drawText(12, 44, 0x00FF00, "ERROR")
			engine.drawText(12, 45, 0x00FF00, "REDUNDANT OPERAND")
			engine.update()
			return nil, true
		
		end
		i = i + 1
		if i > 39 and i<#cmdCur then drawFrom = drawFrom+1 > #cmdCur and drawFrom or drawFrom + 1 end
	end
	drawFrom = 1
	i = 1
	while i<=#cmdCur do
		sOpY = sOpY + 1
		if sOpY > 39 and sOpY<#cmdCur then drawFrom = drawFrom+1 > #cmdCur and drawFrom or drawFrom + 1 end
		drawEdit(locale.stop, true)
		local cmd = cmdCur[i]
		local num = (cmd[2] == 'A' and a) or (cmd[2] == 'B' and b) or (cmd[2] == 'X' and x) or (cmd[2] == 'Y' and y) or cmd[2]
		local num2 = (cmd[3] == 'A' and a) or (cmd[3] == 'B' and b) or (cmd[3] == 'X' and x) or (cmd[3] == 'Y' and y) or cmd[3]
		if cmd[1] == 'INT' then
			if num == 42 then
				plotW = false
			elseif num == 43 then
				plotW = true
				vyzhCur[plotY+1][plotX+1] = 1
				drawTab()
			elseif num == 44 then
				local truX = (x < 0 and 0) or (x > 31 and 31) or x
				local truY = (y < 0 and 0) or (y > 31 and 31) or y
				while plotX ~= truX or plotY ~= truY do
					plotX = plotX == truX and truX or (plotX > truX and plotX-1 or plotX+1)
					plotY = plotY == truY and truY or (plotY > truY and plotY-1 or plotY+1)
					if plotW then vyzhCur[plotY+1][plotX+1] = 1 drawTab() engine.update() end
					local _, _, t1, t2 = pull(0.01, 'touch')
		if t1 and t2 then
			if t1 >= 117 and t1 <= 140 and t2 >= 44 and t2 <= 46 then return end
		end
				end
			else
				drawEdit(locale.stop, true, true)
				engine.drawText(12, 44, 0x00FF00, "ERROR")
				engine.drawText(12, 45, 0x00FF00, "UNKNOWN INTERRUPTION "..num)
				engine.update()
				while true do
					local _, _, t1, t2 = pull('touch')
					if t1 and t2 then
						if t1 >= 117 and t1 <= 140 and t2 >= 44 and t2 <= 46 then return
						elseif t1 >= 149 and t1 <= 158 and t2 >= 5 and t2 <= 10 then return end
					end
				end
			end
		elseif cmd[1] == 'MOV' then
			if cmd[2] == 'A' then
				a = num2
			elseif cmd[2] == 'B' then
				b = num2
			elseif cmd[2] == 'X' then
				x = num2
			elseif cmd[2] == 'Y' then
				y = num2
			end
		elseif cmd[1] == 'ADD' then
			if cmd[2] == 'A' then
				a = a+num2
			elseif cmd[2] == 'B' then
				b = b+num2
			elseif cmd[2] == 'X' then
				x = x+num2
			elseif cmd[2] == 'Y' then
				y = y+num2
			end
		elseif cmd[1] == 'MUL' then
			if cmd[2] == 'A' then
				a = a*num2
			elseif cmd[2] == 'B' then
				b = b*num2
			elseif cmd[2] == 'X' then
				x = x*num2
			elseif cmd[2] == 'Y' then
				y = y*num2
			end
		elseif cmd[1] == 'CMP' then
			carry = (num < num2 and 0) or (num > num2 and 2) or 1
		elseif cmd[1] == 'JMP' then
			i = i+num < 0 and 0 or i+num
			sOpY = i
			drawFrom = i-39 <= 0 and 1 or i-39  
		elseif cmd[1] == 'JG ' then
			if carry == 2 then i = i+num < 0 and 0 or i+num sOpY = i drawFrom = i-39 <= 0 and 1 or i-39 end
		elseif cmd[1] == 'JE ' then
			if carry == 1 then i = i+num < 0 and 0 or i+num sOpY = i drawFrom = i-39 <= 0 and 1 or i-39 end
		elseif cmd[1] == 'JL ' then
			if carry == 0 then i = i+num < 0 and 0 or i+num sOpY = i drawFrom = i-39 <= 0 and 1 or i-39 end
		end
		local _, _, t1, t2 = pull(0.01, 'touch')
		if t1 and t2 then
			if t1 >= 117 and t1 <= 140 and t2 >= 44 and t2 <= 46 then return end
		end
		i = i + 1
	end
	if pattEq() then
		local txt = locale.patEqual or tmissing
		engine.drawText(111-math.ceil(ulen(txt)/2), 27, 0x00FF00, txt)
		frRun = false
		return true
	else
		local txt = locale.patNotEqual or tmissing
		engine.drawText(111-math.ceil(ulen(txt)/2), 27, 0xFF0000, txt)
		if frRun then
			drawEdit(locale.exec)
			os.sleep(1.5)
			msgBox(locale.errFirst or {tmissing}, locale.ok or tmissing)
			engine.drawImage(1, 1, bcontrp)
			drawTab()
			engine.drawText(111-math.ceil(ulen(txt)/2), 27, 0xFF0000, txt)
		end
		frRun = false
	end
end

local function addNum(num)
	if type(cmdCur[sOpY][sOpX]) == 'number' or cmdCur[sOpY][sOpX] == '-' then
		if #tostring(cmdCur[sOpY][sOpX]) < 4 then
			cmdCur[sOpY][sOpX] = math.ceil(tonumber(tostring(cmdCur[sOpY][sOpX])..num))
		end
	else
		cmdCur[sOpY][sOpX] = math.ceil(num)
	end
end

local function editor()
	local stat, err
	engine.drawImage(1, 1, bcontrp)
	drawTab()
	drawEdit(locale.exec)
	if frOp then
		msgBox(locale.editFirst or {tmissing}, locale.ok or tmissing)
		frOp = false
		engine.drawImage(1, 1, bcontrp)
		drawTab()
	end
	while true do
		local typ, _, touch, key = pull()
		if typ == "key_down" then
			stat, err = nil, nil
			if key == 200 then
				sOpY = sOpY-1 == 0 and 1 or sOpY-1
				if sOpY >= 40 then drawFrom = drawFrom - 1 end
			elseif key == 208 then
				sOpY = sOpY+1 > #cmdCur and #cmdCur or sOpY+1
				if sOpY > 39 and sOpY<#cmdCur then drawFrom = drawFrom+1 > #cmdCur and drawFrom or drawFrom + 1 end
			elseif key == 203 then
				sOpX = sOpX-1 == 0 and 1 or sOpX-1
			elseif key == 205 then
				sOpX = sOpX+1 == 4 and 3 or sOpX+1
			elseif key == 16 then return
			elseif key == 35 then if qHelp() then return end
			elseif key == 28 then 
				sOpY = sOpY+1
				table.insert(cmdCur, sOpY, {'', '', ''})
				sOpX = 1
				if sOpY > 39 then drawFrom = drawFrom + 1 end
			elseif key == 211 then
				if #cmdCur > 1 then 
					table.remove(cmdCur, sOpY)
					sOpY = sOpY-1 == 0 and 1 or sOpY-1
				end
				if sOpY >= 40 then drawFrom = drawFrom - 1 end
			elseif key >= 2 and key <= 11 and sOpX > 1 then
				addNum(key == 11 and 0 or key-1)
			elseif key == 12 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = '-'
			elseif key == 14 then
				cmdCur[sOpY][sOpX] = ''
			elseif key == 30 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = 'A' sOpX = sOpX+1 == 4 and 3 or sOpX+1
			elseif key == 48 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = 'B' sOpX = sOpX+1 == 4 and 3 or sOpX+1
			elseif key == 45 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = 'X' sOpX = sOpX+1 == 4 and 3 or sOpX+1
			elseif key == 21 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = 'Y' sOpX = sOpX+1 == 4 and 3 or sOpX+1
			elseif key == 50 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'MOV' sOpX = sOpX+1
			elseif key == 30 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'ADD' sOpX = sOpX+1
			elseif key == 22 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'MUL' sOpX = sOpX+1
			elseif key == 46 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'CMP' sOpX = sOpX+1
			elseif key == 34 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'JG ' sOpX = sOpX+1
			elseif key == 19 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'JE ' sOpX = sOpX+1
			elseif key == 38 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'JL ' sOpX = sOpX+1
			elseif key == 36 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'JMP' sOpX = sOpX+1
			elseif key == 23 and sOpX == 1 then
				cmdCur[sOpY][sOpX] = 'INT' sOpX = sOpX+1
			end
		elseif typ == "touch" then
			stat, err = nil, nil
			if touch >= 149 and touch <= 158 and key >= 5 and key <= 10 then return
			elseif touch >= 117 and touch <= 140 and key >= 44 and key <= 46 then
				stat, err = execute()
				if stat then
					drawEdit(locale.exec)
					os.sleep(1.5)
					return true
				end
			elseif touch >= 82 and touch <= 90 and key >= 33 and key <= 35 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'MOV' sOpX = sOpX+1
				else
					addNum(1)
				end
			elseif touch >= 94 and touch <= 102 and key >= 33 and key <= 35 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'ADD' sOpX = sOpX+1
				else
					addNum(2)
				end
			elseif touch >= 105 and touch <= 114 and key >= 33 and key <= 35 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'MUL' sOpX = sOpX+1
				else
					addNum(3)
				end
			elseif touch >= 117 and touch <= 126 and key >= 33 and key <= 35 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = 'X' sOpX = sOpX+1 == 4 and 3 or sOpX+1
			elseif touch >= 130 and touch <= 138 and key >= 33 and key <= 35 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = 'Y' sOpX = sOpX+1 == 4 and 3 or sOpX+1
			elseif touch >= 82 and touch <= 90 and key >= 36 and key <= 38 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'CMP' sOpX = sOpX+1
				else
					addNum(4)
				end
			elseif touch >= 94 and touch <= 102 and key >= 36 and key <= 38 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'JG ' sOpX = sOpX+1
				else
					addNum(5)
				end
			elseif touch >= 105 and touch <= 114 and key >= 36 and key <= 38 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'JE ' sOpX = sOpX+1
				else
					addNum(6)
				end
			elseif touch >= 117 and touch <= 126 and key >= 36 and key <= 38 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'JL ' sOpX = sOpX+1
				else
					cmdCur[sOpY][sOpX] = 'A' sOpX = sOpX+1 == 4 and 3 or sOpX+1
				end
			elseif touch >= 130 and touch <= 138 and key >= 36 and key <= 38 then
				if sOpX == 1 then
					cmdCur[sOpY][sOpX] = 'JMP' sOpX = sOpX+1
				else
					cmdCur[sOpY][sOpX] = 'B' sOpX = sOpX+1 == 4 and 3 or sOpX+1
				end
			elseif touch >= 82 and touch <= 90 and key >= 39 and key <= 41 then
				if sOpX == 1 then
					cmdCur[sOpY] = {'INT', 42, ''}  sOpY = sOpY+1
					 if not cmdCur[sOpY] then table.insert(cmdCur, {'', '', ''}) end
				else
					addNum(7)
				end
			elseif touch >= 94 and touch <= 102 and key >= 39 and key <= 41 then
				if sOpX == 1 then
					cmdCur[sOpY] = {'INT', 43, ''}  sOpY = sOpY+1
					if not cmdCur[sOpY] then table.insert(cmdCur, {'', '', ''}) end
				else
					addNum(8)
				end
			elseif touch >= 105 and touch <= 114 and key >= 39 and key <= 41 then
				if sOpX == 1 then
					cmdCur[sOpY] = {'INT', 44, ''}  sOpY = sOpY+1
					if not cmdCur[sOpY] then table.insert(cmdCur, {'', '', ''}) end
				else
					addNum(9)
				end
			elseif touch >= 117 and touch <= 126 and key >= 39 and key <= 41 and sOpX > 1 then
				addNum(0)
			elseif touch >= 130 and touch <= 138 and key >= 39 and key <= 41 and sOpX > 1 then
				cmdCur[sOpY][sOpX] = '-'
			elseif touch >= 82 and touch <= 90 and key >= 42 and key <= 44 then
				if qHelp() then return end
			end
		end
	if not err then drawEdit(locale.exec) end
	end
end

local function checkRes(stat)
	engine.drawRectangle(1, 1, 160, 50, 0xA5A5A5, 0xA5A5A5, " ")
	engine.update()
	if stat then
		totalInst = totalInst + #cmdCur
		if locale.taskSolved then locale.taskSolved[3] = tostring(#cmdCur) end
		if not loadTsk() then
			if locale.taskSolved then table.remove(locale.taskSolved) table.remove(locale.taskSolved) end
			msgBox(locale.taskSolved or {tmissing}, locale.ok or tmissing, nil, true)
			engine.drawRectangle(1, 1, 160, 50, 0xA5A5A5, 0xA5A5A5, " ")
			if locale.allTasksSolved then locale.allTasksSolved[3] = tostring(totalInst) end
			msgBox(locale.allTasksSolved or {tmissing}, locale.restart or tmissing, nil, true)
			vClean()
			taskNum = 1
			totalInst = 0
			cmdCur = {
				{'INT', 42, ''},
				{'MOV', 'X', 0},
				{'MOV', 'Y', 0},
				{'INT', 44, ''},
				{'INT', 43, ''},
				{'MOV', 'X', 15},
				{'MOV', 'Y', 15},
				{'INT', 44, ''}
			}
			loadTsk()
		else
			msgBox(locale.taskSolved or {tmissing}, locale.ok or tmissing, nil, true)
		end
	end
	drawMenu()
end

pull(1, 'key_down')
engine.drawText(math.ceil(80-(ulen(locale.gameBy or tmissing)/2)), 25, 0xFFFFFF, locale.gameBy or tmissing)
engine.update()
pull(2, 'key_down')
engine.drawImage(50, 16, cidlogo)
engine.update()
pull(2.5, 'key_down')
engine.clear()
engine.drawText(math.ceil(80-(ulen(locale.andBy or tmissing)/2)), 25, 0xFFFFFF, locale.andBy or tmissing)
engine.update()
pull(2, 'key_down')
engine.drawImage(60, 18, comlogo)
engine.update()
pull(2.5, 'key_down')
engine.clear()
engine.update()
pull(1, 'key_down')

for i=30,5,-5 do
	engine.clear()
	engine.drawImage(30, i, gamelogo)
	engine.update()
	os.sleep(0.2)
end
engine.drawText(65, 3, 0xFFFFFF, "2019 (c)  CAT IN THE DARK")
engine.drawText(65, 4, 0xFFFFFF, "2021 (c)  Compys S&N Systems")
engine.drawText(161-#gVER, 50, 0xFFFFFF, gVER)
engine.drawText(67, 47, 0xFFFFFF, "Press any key to continue!")
engine.update()
pull("key_down")

engine.drawRectangle(1, 1, 160, 50, 0xA5A5A5, 0xA5A5A5, " ")
msgBox(locale.welcome or {tmissing}, locale.ok or tmissing)
vClean()
loadTsk()
drawMenu()
local work = true
local opt = true
local posed, posta = math.ceil(50-(ulen(locale.editor or tmissing)/2)), math.ceil(110-(ulen(locale.task or tmissing)/2))


while work do
	engine.drawRectangle( 1, 14, 160, 23, 0xA5A5A5, 0xA5A5A5, " ")
	if opt then
		engine.drawRectangle(32, 17, 38, 16, 0xFF0000, 0xFF0000, " ")
		engine.drawRectangle(posed-1, 36, ulen(locale.editor or tmissing)+2, 1, 0xFF0000, 0xFFFFFF, " ")
		engine.drawText(posed, 36, 0xFFFFFF, locale.editor or tmissing)
		engine.drawText(posta, 36, 0x000000, locale.task or tmissing)
	else
		engine.drawRectangle(94, 15, 34, 19, 0xFF0000, 0xFF0000, " ")
		engine.drawRectangle(posta-1, 36, ulen(locale.task or tmissing)+2, 1, 0xFF0000, 0xFFFFFF, " ")
		engine.drawText(posed, 36, 0x000000, locale.editor or tmissing)
		engine.drawText(posta, 36, 0xFFFFFF, locale.task or tmissing)
	end
	engine.drawImage(34, 18, editrp)
	engine.drawImage(96, 16, taskp)
	engine.update()
	local typ, _, touch, key = pull()
	if typ == "key_down" then
		if key == 203 or key == 205 then opt = not opt
		elseif key == 16 then work = false
		elseif key == 23 then about() drawMenu()
		elseif key == 35 then help() drawMenu()
		elseif key == 28 then
			if opt then 
				local stat = editor()
				checkRes(stat)
			else msgBox({locale.taskCapt or tmissing}, locale.ok or tmissing, tsk) end
			drawMenu()
		end
	elseif typ == "touch" then
		if touch >= 34 and touch <= 67 and key >= 18 and key <= 32 then
			local stat = editor()
			checkRes(stat)
		elseif touch >= 96 and touch <= 125 and key >= 16 and key <= 32 then
			msgBox({locale.taskCapt or tmissing}, locale.ok or tmissing, tsk)
			drawMenu()
		elseif touch >= 4 and touch <= 11 and key >= 2 and key <= 5 then
			about() drawMenu()
		elseif touch >= 150 and touch <= 157 and key >= 2 and key <= 5 then
			help() drawMenu()
		elseif touch >= 150 and touch <= 157 and key >= 46 and key <= 49 then
			work = false
		end
	end
end
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()
print((locale.goodBye or tmissing)..'\n')