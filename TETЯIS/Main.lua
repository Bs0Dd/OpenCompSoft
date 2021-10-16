local GUI = require("GUI")
local system = require("System")
local screen = require("Screen")
local image = require("Image")
local fs = require("Filesystem")
local event = require("Event")

---------------------------------------------------------------------------------

local workspace, window, menu = system.addWindow(GUI.window(1, 1, 38, 46))

window.draw = GUI.container().draw


local progpat = fs.path(system.getCurrentScript())..'Resources/'

local gover = fs.readTable(progpat..'Gameover.scd')
local youwin = fs.readTable(progpat..'Youwin.scd')
local pause = fs.readTable(progpat..'Pause.scd')

local tetralist =  fs.readTable(progpat..'Tetramino.scl')

local fulldisp, minidisp
local speed, scor, hiscor, level, hiscores
local gmode, snakemap, snakehead, direct, rspeed
local ltime = os.time()
local xApple, yApple
local paused, stopped = false, true
local dspback, scorsp
local klok = false
local snwaspaused = false
local curtet, nextet, sumrows, xcur, ycur


local function dispInit(x, y)
	local disp = {} 
	for i=1, y do
		table.insert(disp, {})
		for j=1, x do
			disp[i][j] = false
		end
	end
	return disp
end

window:addChild(GUI.image(1, 1, image.load(progpat.."Device.pic")))

local function dispDraw(disp, strtX, strtY)
	for i=1, #disp do
		for j=1, #disp[i] do
			screen.set(strtX+(j*2)-2, strtY+i-1, 0xCCDBBF, disp[i][j] and 0x000000 or 0xC3C3C3, "⠶")
		end
	end
end


local function getTminBitmap(num)
	local copy = {}
	for i=1, #tetralist[num] do
		table.insert(copy, {})
		for j=1, #tetralist[num][1] do
			table.insert(copy[i], tetralist[num][i][j])
		end
	end
	return copy
end

local function rotateBitmap(bitmap)
	local rotated = {}
	for i=1, #bitmap[1] do
		table.insert(rotated, {})
		for j=1, #bitmap do
			table.insert(rotated[i], bitmap[#bitmap-j+1][i])
		end
	end
	return rotated
end

local function drawBitmap(screen, bitmap, x, y, erase)
	for i=1, #bitmap do
		for j=1, #bitmap[1] do
			if bitmap[i][j] then
				screen[y+i-1][x+j-1] = not erase and true or false
			end 
		end
	end
end

local function drawNext()
	minidisp = dispInit(4, 4)
	drawBitmap(minidisp, nextet, 1, 5 - #nextet)
end


if not fs.exists(progpat.."Hiscores.scf") then
	hiscores = {tetris = 0, snake = 0}
	fs.writeTable(progpat.."Hiscores.scf", hiscores)
else
	hiscores = fs.readTable(progpat.."Hiscores.scf")
end


local function butConstr(x, y, w, h, call, nopau, nost)
	local but = GUI.object(x, y, w, h)
	window:addChild(but).eventHandler = function(_, _, typ)
		if typ == 'touch' and (nopau and true or not paused) and (nost and true or not stopped) then
			call()
		end
	end
end

butConstr(2, 3, 1, 1, function() window:remove() workspace:draw() end, true, true)

butConstr(37, 3, 1, 1, function() window:minimize() workspace:draw() end, true, true)


local function snakeColl(x, y)
	for i = 1, #snakemap do
		if snakemap[i][1] == x and snakemap[i][2] == y then
			return true
		end
	end
	return false
end

local function spawnApple()
	while true do
		if #snakemap >= 199 then return false end
		
		local x, y = math.random(1, 10), math.random(1, 20)
		local success = true
		
		for i = 1, #snakemap do
			if snakeColl(x, y) then
				success = false
				break
			end
		end
		
		if success then
			xApple, yApple = x, y
			fulldisp[y][x] = true
			return true
		end
	end
end


local function stopGame(screen)
	fulldisp = screen
	fs.writeTable(progpat.."Hiscores.scf", hiscores)
	stopped = true
	workspace:draw()
end


local function isColliz(tetmin, x, y)
	tminsiz = #tetmin
	if y + tminsiz-1 > 20 then return true end
	for i=1, tminsiz do
		for j=1, #tetmin[i] do
			if tetmin[i][j] and fulldisp[i+y-1][j+x-1] then return true end
		end
	end
	return false
end

local function checkFullRow()
	local rows = 0
	local sw = true
	for i = 1, 20 do
		for j = 1, 10 do
			if not fulldisp[i][j] then sw = false break end
		end
		if sw then
			rows = rows + 1
			table.remove(fulldisp, i)
			table.insert(fulldisp, 1, {false, false, false, false, false, false, false, false, false, false})
		end
		sw = true
	end
	sumrows = sumrows + rows
	if sumrows >= 4 and speed < 9 then
		rspeed = rspeed - 5
		speed = speed + 1
		sumrows = sumrows - 4
	end
	scor = (rows == 0 and scor + 5) or (rows == 1 and scor + 10) or (rows == 2 and scor + 20) or (rows == 3 and scor + 50) or scor + 80
	if scor > hiscor then hiscor = scor end
end

local function moveX(dir)
	if xcur + dir + #curtet[1] -1 > 10 or xcur + dir < 1 then return end
	drawBitmap(fulldisp, curtet, xcur, ycur, true)
	local coll = isColliz(curtet, xcur + dir, ycur)
	xcur = coll and xcur or xcur + dir
	drawBitmap(fulldisp, curtet, xcur, ycur)
	workspace:draw()
end

local function moveDown(noupdate)
	drawBitmap(fulldisp, curtet, xcur, ycur, true)
	ycur = ycur + 1
	local coll = isColliz(curtet, xcur, ycur)
	if coll then
		drawBitmap(fulldisp, curtet, xcur, ycur-1)
		checkFullRow()
		curtet = nextet
		nextet = getTminBitmap(math.random(7))
		xcur, ycur = 6 - math.floor(#curtet[1]/2), 1
		drawNext()
		if isColliz(curtet, xcur, ycur) then
			hiscores.tetris = hiscor
			stopGame(gover)
			return
		end
	end
	drawBitmap(fulldisp, curtet, xcur, ycur)
	if not noupdate then workspace:draw() ltime = os.time() end
end



local function startTetris()
	math.randomseed(os.time())
	speed, scor, level = 1, 0, 1
	hiscor = hiscores.tetris
	fulldisp = dispInit(10, 20)
	minidisp = dispInit(4, 4)
	curtet = getTminBitmap(math.random(7))
	nextet = getTminBitmap(math.random(7))
	xcur, ycur = 6 - math.floor(#curtet[1]/2), 1
	drawBitmap(fulldisp, curtet, xcur, ycur)
	drawNext()
	gmode = true
	rspeed = 50
	sumrows = 0
	stopped, paused = false, false
end

local function startSnake()
	snakemap = {{5, 5}, {5, 6}, {5, 7}}
	direct = 4
	scorsp = 0
	snakehead = {5, 7}
	fulldisp = dispInit(10, 20)
	minidisp = dispInit(4, 4)
	fulldisp[5][5] = true
	fulldisp[6][5] = true
	fulldisp[7][5] = true
	speed, scor, level = 1, 0, 1
	gmode = false
	direct = 2
	rspeed = 50
	hiscor = hiscores.snake
	spawnApple()
	stopped, paused = false, false
end


local dispobj = window:addChild(GUI.object(5, 4, 16, 20))

--startSnake()
startTetris()

dispobj.draw = function(obj)
	dispDraw(fulldisp, obj.x, obj.y)
	dispDraw(minidisp, obj.x+22, obj.y+8)
	screen.drawRectangle(obj.x+21, obj.y+2, 8, 1, 0xCCDBBF, 0x000000, " ")
	screen.drawText(obj.x+25-(math.ceil(#tostring(scor)/2)), obj.y+2, 0x000000, tostring(scor))
	screen.drawRectangle(obj.x+21, obj.y+5, 8, 1, 0xCCDBBF, 0x000000, " ")
	screen.drawText(obj.x+25-(math.ceil(#tostring(hiscor)/2)), obj.y+5, 0x000000, tostring(hiscor))
	screen.drawRectangle(obj.x+21, obj.y+14, 8, 1, 0xCCDBBF, 0x000000, " ")
	screen.drawText(obj.x+25-(math.ceil(#tostring(speed)/2)), obj.y+14, 0x000000, tostring(speed))
	screen.drawRectangle(obj.x+21, obj.y+17, 8, 1, 0xCCDBBF, 0x000000, " ")
	screen.drawText(obj.x+25-(math.ceil(#tostring(level)/2)), obj.y+17, 0x000000, tostring(level))
end


local function dirButExec(funcTet, dc, d)
	if not paused and not stopped then
		if gmode then
			funcTet()
		else
			if direct ~= dc and not klok then
				direct = d
				klok = true
			end
		end
	end
end

local function butRotate()
	drawBitmap(fulldisp, curtet, xcur, ycur, true)
	rotatd = rotateBitmap(curtet)
	curtet = (isColliz(rotatd, xcur, ycur) or xcur + #rotatd[1]-1 > 10) and curtet or rotatd
	drawBitmap(fulldisp, curtet, xcur, ycur)
	workspace:draw()
end

butConstr(9, 36, 6, 3, function() dirButExec(butRotate, 2, 1) end)

butConstr(9, 42, 6, 3, function() dirButExec(moveDown, 1, 2) end)

butConstr(3, 39, 6, 3, function() dirButExec(function() moveX(-1) end, 4, 3) end)

butConstr(15, 39, 6, 3, function() dirButExec(function() moveX(1) end, 3, 4) end)


local function butMid()
	paused = not paused
	if paused then
		dspback = minidisp
		minidisp = fs.readTable(progpat..'Pause.scd')
	else
		minidisp = dspback
	end
	workspace:draw()
end

local function butNew()
	if gmode then
		startTetris()	
	else
		startSnake()
	end
	workspace:draw()
end

local function butMode()
	gmode = not gmode
	butNew()
end

butConstr(26, 38, 8, 8, butMid, true)

butConstr(29, 44, 6, 1, butNew, true, true)

butConstr(20, 44, 6, 1, butMode, true, true)


dispobj.eventHandler = function(_, _, ev, _, _, code)
	if not paused and snwaspaused then fulldisp[snakehead[2]][snakehead[1]] = true workspace:draw() snwaspaused = false end
	if ev == 'key_down' then
		if code == 200 then dirButExec(butRotate, 2, 1)
		elseif code == 208 then dirButExec(moveDown, 1, 2) 
		elseif code == 203 then dirButExec(function() moveX(-1) end, 4, 3) 
		elseif code == 205 then dirButExec(function() moveX(1) end, 3, 4) 
		elseif code == 28 and not stopped then butMid()
		elseif code == 49 then butNew()
		elseif code == 50 then butMode()
		end
	end
	if not paused and not stopped then
		if ltime + rspeed <= os.time() then
			if gmode then
				moveDown(true)
			else
				klok = false
				local newhead
				if direct == 1 then newhead = {snakehead[1], snakehead[2] == 1 and 20 or snakehead[2]-1}
				elseif direct == 2 then newhead = {snakehead[1], snakehead[2] == 20 and 1 or snakehead[2]+1}
				elseif direct == 3 then newhead = {snakehead[1] == 1 and 10 or snakehead[1]-1, snakehead[2]}
				else newhead = {snakehead[1] == 10 and 1 or snakehead[1]+1, snakehead[2]} end
				if snakeColl(newhead[1], newhead[2]) then
					hiscores.snake = hiscor
					stopGame(gover)
					return
				end
				table.insert(snakemap, newhead)
				if newhead[1] == xApple and newhead[2] == yApple then
					scor = scor + 50
					scorsp = scorsp + 1
					if scorsp == 5 and speed < 9 then
						scorsp = 0
						rspeed = rspeed - 5
						speed = speed + 1
					end
					if scor > hiscor then hiscor = scor end
					if not spawnApple() then
						hiscores.snake = hiscor
						stopGame(youwin)
						return
					end
				else
					fulldisp[snakemap[1][2]][snakemap[1][1]] = false
					table.remove(snakemap, 1)
					scor = scor == 0 and scor or scor - 1
				end
				snakehead = newhead
				fulldisp[snakehead[2]][snakehead[1]] = true
			end
			workspace:draw()
			ltime = os.time()
		end
	elseif paused and not gmode and ltime + 50 <= os.time() then
		fulldisp[snakehead[2]][snakehead[1]] = not fulldisp[snakehead[2]][snakehead[1]]
		workspace:draw()
		ltime = os.time()
		snwaspaused = true
	end
end

---------------------------------------------------------------------------------

workspace:draw()
