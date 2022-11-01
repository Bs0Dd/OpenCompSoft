local gVER = "v1.00"

local engine = require("NyaDraw")
local component = require("component")
local unicode = require("unicode")
local fs = require('filesystem')
local srz = require("serialization")
local term = require("term")
local event = require("event")
local shell = require("shell")
local kb = require("keyboard")

local ulen = unicode.len
local usub = unicode.sub

local gpu = component.gpu
if gpu.maxDepth() < 8 then
	io.stderr:write("Error: Your graphics card or monitor doesn't support 256 colors\n")
	return
end
gpu.setResolution(160, 50)
gpu.setDepth(8)

term.clear()

engine.setGPUProxy(gpu)
engine.update(true)

local taskp = engine.loadImage("Pictures/task.pic")

local vyzhCur
local ismod, infst, fpath = false, false

local vvptask = {{26, 30, 2, 4}, {28, 34, 2, 4}, {30, 38, 4, 1}, {34, 34, 2, 4},
				{36, 30, 2, 4}, {42, 30, 2, 4}, {44, 34, 2, 4}, {46, 38, 4, 1},
				{50, 34, 2, 4}, {52, 30, 2, 4}, {58, 30, 2, 9}, {60, 30, 8, 1},
				{60, 34, 8, 1}, {68, 31, 2, 3}, {79, 30, 2, 9}, {74, 30, 12, 1},
				{90, 35, 2, 3}, {92, 30, 8, 1}, {92, 34, 8, 1}, {92, 38, 8, 1},
				{100, 31, 2, 8}, {109, 30, 10, 1}, {107, 31, 2, 3}, {109, 34, 8, 1},
				{117, 35, 2, 3}, {107, 38, 10, 1}, {124, 30, 2, 9}, {134, 32, 2, 1},
				{132, 33, 2, 1}, {130, 34, 2, 1}, {126, 35, 4, 1}, {130, 36, 2, 1},
				{132, 37, 2, 1}, {134, 38, 2, 1}}

local function vClean()
	vyzhCur = {}
	for i=1, 32, 1 do
		vyzhCur[i] = {}
		for j=1, 32, 1 do
			vyzhCur[i][j] = 0
		end
	end
end


local function drawTab()
	local k = 1
	for i=1, 32, 2 do
		for j=1, 32, 1 do
			engine.set(j+101, k+25, vyzhCur[i][j] == 1 and 0x00FF00 or 0x1E1E1E, vyzhCur[i+1][j] == 1 and 0x00FF00 or 0x1E1E1E, "▄")
		end
		k = k + 1
	end
end

local function drawBig()
	local k = 1
	for i=1, 32, 1 do
		for j=1, 32, 1 do
			engine.drawText(j*2+19, k+9, vyzhCur[i][j] == 1 and 0x00FF00 or ((j + k) % 2 == 0 and 0x1E1E1E or 0x4B4B4B), "██")
		end
		k = k + 1
	end
end

local function drwBt(x, y, text)
	engine.drawRectangle(x+1, y, ulen(text), 1, 0x1E1E1E, 0x0000FF, " ")
	engine.drawText(x+1, y, 0x00FF00, text)
	engine.set(x, y, 0x0000FF, 0x1E1E1E,"⢾")
	engine.set(x+ulen(text)+1, y, 0x0000FF, 0x1E1E1E,"⡷")
end

local function drwBox(x, y, xlen, ylen)
	engine.drawRectangle(x, y, xlen, ylen, 0x0000FF, 0xA5A5A5, " ")
	engine.set(x, y, 0xA5A5A5, 0x0000FF,"⣴")
	engine.set(x, y+ylen-1, 0xA5A5A5, 0x0000FF,"⠻")
	engine.set(x+xlen-1, y, 0xA5A5A5, 0x0000FF,"⣦")
	engine.set(x+xlen-1, y+ylen-1, 0xA5A5A5, 0x0000FF,"⠟")
end

local function drawWindow()
	engine.drawRectangle(1, 1, 160, 50, 0xA5A5A5, 0xA5A5A5, " ")
	engine.drawRectangle(1, 1, 160, 3, 0xFFFFFF, 0xA5A5A5, " ")
	engine.drawRectangle(1, 48, 160, 3, 0xFFFFFF, 0xA5A5A5, " ")
	engine.drawRectangle(1, 1, 19, 3, 0x1E1E1E, 0xA5A5A5, " ")
	engine.drawText(4, 2, 0x00FF00, "VVPTask "..gVER)
	engine.drawText(24, 2, 0x000000, "New")
	engine.drawLine(31, 1, 31, 3, 0x1E1E1E, 0xA5A5A5, " ")
	engine.drawText(36, 2, 0x000000, "Load")
	engine.drawLine(44, 1, 44, 3, 0x1E1E1E, 0xA5A5A5, " ")
	engine.drawText(49, 2, 0x000000, "Save")
	engine.drawLine(57, 1, 57, 3, 0x1E1E1E, 0xA5A5A5, " ")
	engine.drawText(62, 2, 0x000000, "Save as")
	engine.drawLine(73, 1, 73, 3, 0x1E1E1E, 0xA5A5A5, " ")
	engine.drawText(78, 2, 0x000000, "Help")
	engine.drawLine(86, 1, 86, 3, 0x1E1E1E, 0xA5A5A5, " ")
	engine.drawText(91, 2, 0x000000, "Exit")
	engine.drawLine(99, 1, 99, 3, 0x1E1E1E, 0xA5A5A5, " ")
	engine.drawText(43, 49, 0x000000, "Official tasks editor for VychVyzhProm || 2021-2022 (c) Compys S&N Systems")

	drwBox(99, 23, 38, 21)
	drwBt(108, 24, "Controller display")
	drwBox(18, 7, 70, 37)
	drwBt(43, 8, "Task edit touchpad")
	drwBox(92, 7, 52, 15)
	drwBt(111, 8, "Status panel")
end

local function drawPanel()
	engine.drawText(94, 10, 0xFFFFFF, "File:")
	engine.drawRectangle(94, 11, 48, 1, 0xA5A5A5, 0x0000FF, " ")
	
	local pat
	if fpath == "" then pat = "<New Task>"
	elseif ulen(fpath) > 48 then
		pat = ".."..usub(fpath, -45)
	else
		pat = fpath
	end
	engine.drawText(94, 11, 0xFFFFFF, pat)
	
	if ismod then
		engine.drawRectangle(94, 13, 10, 1, 0x1E1E1E, 0x0000FF, " ")
		engine.drawText(95, 13, 0x00FF00, "MODIFIED")
	end
end

local function enterPath(tcapt)
	engine.drawText(94, 10, 0xFFFFFF, tcapt)
	engine.drawRectangle(94, 11, 48, 1, 0xFFFFFF, 0x000000, " ")
	drwBt(120, 13, "  Ok  ")
	drwBt(131, 13, "Cancel")
	engine.update()
	gpu.setBackground(0xFFFFFF)
	gpu.setForeground(0x000000)
	local inp = fpath
	local seen
	while true do
		if ulen(inp) > 48 then seen ='..'..usub(inp,-46) else seen = inp end
		gpu.set(94, 11, seen)
		term.setCursor(ulen(seen) < 48 and 94+ulen(seen) or 141, 11)
		local eve,_,sym,key = term.pull()
		if eve == "key_down" then
			if sym == 8 then
				inp = usub(inp,1,-2)
				if ulen(seen) > 0 then gpu.set(ulen(seen)+93, 11, ' ') end
			elseif sym == 13 then
				return inp
			elseif sym == 0 or sym == 9 or sym == 127 then
			else
				inp = inp..unicode.char(sym)
			end
		elseif eve == "interrupted" or (eve == "touch" and sym >= 131 and sym <= 138 and key == 13) then
			drwBox(92, 7, 52, 15)
			drwBt(111, 8, "Status panel")
			drawPanel()
			engine.update()
			return false
		elseif eve == "touch" and sym >= 120 and sym <= 127 and key == 13 then
			return inp
		elseif eve == "clipboard" then 
			inp = inp..sym
		end
	end
end

local function redrTask()
	drawTab()
	drawBig()
	drawPanel()
	engine.update()
end

local function newTsk()
	fpath = ""
	vClean()
	ismod = false
	drwBox(92, 7, 52, 15)
	drwBt(111, 8, "Status panel")
	redrTask()
end

local function writeArr(path)
	local fld = fs.path(path)
	if not fs.exists(fld) then return false, "The parent directory doesn't exist" end
	if not fs.isDirectory(fld) then return false, "The parent object isn't a directory" end
	if fs.isDirectory(path) then return false, "This is a directory" end
	local rawf, why = io.open(path, "w")
	if not rawf then return false, why end
	rawf:write("{\n{")
	for j=1, 32, 1 do
		for k=1, 32, 1 do
			rawf:write(vyzhCur[j][k])
			if k == 32 and j == 32 then
				rawf:write("}\n}")
			elseif k == 32 then
				rawf:write("},\n{")
			else
				rawf:write(",")
			end
		end
	end
	rawf:close()
	return true
end

local function saveAs()
	local npat = enterPath("Save file:")
	if not npat then return end
	npat = fs.canonical(npat)
	if usub(npat, 1, 1) ~= "/" and not string.match(npat, shell.getWorkingDirectory()) then
		npat = fs.concat(shell.getWorkingDirectory(), npat)
	end
	if fs.exists(npat) and not fs.isDirectory(npat) then
		engine.drawLine(120, 13, 138, 13, 0x0000FF, 0xA5A5A5, " ")
		engine.drawText(112, 16, 0xFFFFFF, "File exists!")
		engine.drawText(104, 17, 0xFFFFFF, "Do you want to overwrite it?")
		drwBt(108, 19, " Yes  ")
		drwBt(120, 19, "  No  ")
		engine.update()
		while true do
			local typ, _, touch, key = event.pull()
			if typ == "touch" and key == 19 then
				if touch >= 108 and touch <= 115 then
					break
				elseif touch >= 120 and touch <= 127 then
					drwBox(92, 7, 52, 15)
					drwBt(111, 8, "Status panel")
					redrTask()
					return
				end
			elseif typ == "interrupted" or (typ == "key_down" and key == 49) then
				drwBox(92, 7, 52, 15)
				drwBt(111, 8, "Status panel")
				redrTask()
				return
			elseif typ == "key_down" and key == 21 then
				break
			end
		end
	end
	local stat, why = writeArr(npat)
	drwBox(92, 7, 52, 15)
	drwBt(111, 8, "Status panel")
	if not stat then
		engine.drawText(108, 17, 0xFF0000, "Failed to save task:")
		engine.drawText(math.floor(118-(ulen(why)/2)), 18, 0xFF0000, why)
	else
		engine.drawText(108, 17, 0x00FF00, "Successfully saved!")
	end
	ismod = false
	infst = true
	fpath = npat
	redrTask()
end

local function saveTsk()
	if ismod then
		if fpath == "" then return saveAs() end
		local stat, why = writeArr(fpath)
		drwBox(92, 7, 52, 15)
		drwBt(111, 8, "Status panel")
		if not stat then
			engine.drawText(108, 17, 0xFF0000, "Failed to save task:")
			engine.drawText(math.floor(118-(ulen(why)/2)), 18, 0xFF0000, why)
		else
			engine.drawText(108, 17, 0x00FF00, "Successfully saved!")
		end
		infst = true
		ismod = false
		redrTask()
	end
end

local function help()
	drwBox(92, 7, 52, 15)
	drwBt(111, 8, "Status panel")
	engine.drawText(93, 10, 0xFFFFFF, "In this editor, you can create your own tasks for")
	engine.drawText(93, 11, 0xFFFFFF, "the game. Tasks are stored as \"/Tasks/task*.vtf\"")
	engine.drawText(93, 12, 0xFFFFFF, "where '*' is the task number. By replacing or")
	engine.drawText(93, 13, 0xFFFFFF, "adding tasks, you can change the game, simplifying")
	engine.drawText(93, 14, 0xFFFFFF, "or complicating it. The touchpad is used to create")
	engine.drawText(93, 15, 0xFFFFFF, "a task. Clicking LMB on it allows you to draw")
	engine.drawText(93, 16, 0xFFFFFF, "patterns, pressing RMB acts as an eraser.")
	engine.drawText(93, 17, 0xFFFFFF, "")
	drwBt(114, 19, "  Ok  ")
	engine.update()
	while true do
		local typ, _, touch, key = event.pull()
		if typ == "touch" and key == 19 and touch >= 114 and touch <= 121 then
			drwBox(92, 7, 52, 15)
			drwBt(111, 8, "Status panel")
			redrTask()
			return
		elseif typ == "interrupted" or (typ == "key_down" and key == 28) then
			drwBox(92, 7, 52, 15)
			drwBt(111, 8, "Status panel")
			redrTask()
			return
		end
	end
end

local function loadTsk(path)
	path = fs.canonical(path)
	if usub(path, 1, 1) ~= "/" and not string.match(path, shell.getWorkingDirectory()) then
		path = fs.concat(shell.getWorkingDirectory(), path)
	end
	if not fs.exists(path) then return false, "The file doesn't exist" end
	if fs.isDirectory(path) then return false, "This is a directory" end
	local rawf, why = io.open(path)
	if not rawf then return false, why end
	local newt, why = srz.unserialize(rawf:read("*a"))
	rawf:close()
	if not newt then return false, why end
	if #newt ~= 32 then return false, "Incorrect array" end
	for i=1,32 do
		if #newt[i] ~= 32 then return false, "Incorrect array" end
	end
	vyzhCur = newt
	fpath = path
	ismod = false
	return true
end

local function ifmDlg()
	if ismod then
		engine.drawText(105, 16, 0xFFFFFF, "The file has been modified")
		engine.drawText(104, 17, 0xFFFFFF, "Do you want to save changes?")
		drwBt(103, 19, " Yes  ")
		drwBt(114, 19, "  No  ")
		drwBt(125, 19, "Cancel")
		engine.update()
		while true do
			local typ, _, touch, key = event.pull()
			if typ == "touch" and key == 19 then
				if touch >= 103 and touch <= 110 then
					drwBox(92, 7, 52, 15)
					drwBt(111, 8, "Status panel")
					drawPanel()
					saveTsk()
					return true
				elseif touch >= 114 and touch <= 121 then
					drwBox(92, 7, 52, 15)
					drwBt(111, 8, "Status panel")
					redrTask()
					return true
				elseif touch >= 125 and touch <= 132 then
					drwBox(92, 7, 52, 15)
					drwBt(111, 8, "Status panel")
					redrTask()
					return false
				end
			elseif typ == "interrupted" or (typ == "key_down" and key == 46) then
				drwBox(92, 7, 52, 15)
				drwBt(111, 8, "Status panel")
				redrTask()
				return false
			elseif typ == "key_down" and key == 49 then
				drwBox(92, 7, 52, 15)
				drwBt(111, 8, "Status panel")
				redrTask()
				return true
			elseif typ == "key_down" and key == 21 then
				drwBox(92, 7, 52, 15)
				drwBt(111, 8, "Status panel")
				drawPanel()
				saveTsk()
				return true
			end
		end
	end
	return true
end

local function openTsk()
	local npat = enterPath("Load file:")
	if not npat then return end
	local stat, why = loadTsk(npat)
	drwBox(92, 7, 52, 15)
	drwBt(111, 8, "Status panel")
	if not stat then
		engine.drawText(108, 17, 0xFF0000, "Failed to load task:")
		engine.drawText(math.floor(118-(ulen(why)/2)), 18, 0xFF0000, why)
	else
		engine.drawText(108, 17, 0x00FF00, "Successfully loaded!")
	end
	infst = true
	redrTask()
end

engine.drawImage(65, 7, taskp)
engine.drawText(63, 3, 0xFFFFFF, "2021 - 2022 (c) Compys S&N Systems")
engine.drawText(161-#gVER, 50, 0xFFFFFF, gVER)
engine.drawText(67, 47, 0xFFFFFF, "Press any key to continue!")

for _, crd in pairs(vvptask) do
		engine.drawRectangle(crd[1], crd[2], crd[3], crd[4], 0x00FF00, 0x000000, " ")
end

engine.update()
event.pull("key_down")

local args = shell.parse(...)

if #args > 0 then
	if not loadTsk(args[1]) then newTsk() end
else
	newTsk()
end
drawWindow()
redrTask()

while true do
	local typ, _, touch, key, bt = event.pull()
	if typ == "touch" then
		if infst then
			infst = false
			drwBox(92, 7, 52, 15)
			drwBt(111, 8, "Status panel")
			drawPanel()
			engine.update()
		end
		if touch >= 21 and key >= 10 and touch <= 84 and key <= 41 then
			if not ismod then
				ismod = true
				engine.drawRectangle(94, 13, 10, 1, 0x1E1E1E, 0x0000FF, " ")
				engine.drawText(95, 13, 0x00FF00, "MODIFIED")
			end
			vyzhCur[key-9][math.ceil((touch-20)/2)] = math.floor(1-bt)
			drawTab()
			drawBig()
			engine.update()
		elseif key >= 1 and key <= 3 then
			if touch >= 20 and touch <= 30 then
				if ifmDlg() then newTsk() end
			elseif touch >= 32 and touch <= 43 then
				if ifmDlg() then openTsk() end
			elseif touch >= 45 and touch <= 56 then
				saveTsk()
			elseif touch >= 58 and touch <= 72 then
				saveAs()
			elseif touch >= 74 and touch <= 85 then
				help()
			elseif touch >= 87 and touch <= 98 then
				if ifmDlg() then break end
			end
		end
	elseif typ == "drag" and touch >= 21 and key >= 10 and touch <= 84 and key <= 41 then
		if not ismod then
			ismod = true
			engine.drawRectangle(94, 13, 10, 1, 0x1E1E1E, 0x0000FF, " ")
			engine.drawText(95, 13, 0x00FF00, "MODIFIED")
		end
		vyzhCur[key-9][math.ceil((touch-20)/2)] = math.floor(1-bt)
		if infst then
			infst = false
			drwBox(92, 7, 52, 15)
			drwBt(111, 8, "Status panel")
			redrTask()
		else
			drawTab()
			drawBig()
			engine.update()
		end
	elseif typ == "key_down" then
		if infst then
			infst = false
			drwBox(92, 7, 52, 15)
			drwBt(111, 8, "Status panel")
			drawPanel()
			engine.update()
		end
		if kb.isControlDown() then
			if key == 49 then
				if ifmDlg() then newTsk() end
			elseif key == 38 then
				if ifmDlg() then openTsk() end
			elseif kb.isAltDown() and key == 31 then
				saveAs()
			elseif key == 31 then
				saveTsk()
			elseif key == 35 then
				help()
			elseif key == 18 then
				if ifmDlg() then break end
			end
		end
	elseif typ == "interrupted" then break
	end
end

gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()
print("Thanks for using VVPTask!\n")
