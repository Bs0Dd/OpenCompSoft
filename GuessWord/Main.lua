local GUI = require("GUI")
local system = require("System")
local fs = require("Filesystem")
local image = require("Image")
local unicode = require("Unicode")
local screen = require("Screen")

local ulen = unicode.len
local uup = unicode.upper
local uchar = unicode.char

---------------------------------------------------------------------------------
local playUser, diff, startd = system.getUser() 
local lives, scor, hiscor, hiscores, oldtouch
local lastnum, num, combo = 0, 0, 1

local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 81, 30, 0xFFFFFF))
window.actionButtons.localY = 1
window.actionButtons.maximize.hidden = true

--[[window.eventHandler = function(_, o, typ, _, x, y)
	if typ == 'touch' then print(x-o.x+1, y-o.y+1) end
end]]

local function realListSiz(list)
	local siz = 0
	for _, _ in pairs(list) do
		siz = siz+1
	end
	return siz
end


local function letterForLay(letter)
	local obj = GUI.object(1, 1, 5, 3)
	obj.letter = letter
	obj.showLetter = false
	obj.draw = function(obj)
		screen.drawRectangle(obj.x, obj.y, obj.width, obj.height, 0x3C3C3C, 0x000000, " ")
		if obj.showLetter then screen.set(obj.x+2, obj.y+1, 0x3C3C3C, 0xFFFFFF, obj.letter) end
	end
	return obj
end

local function livesText()
	local obj = GUI.object(1, 5, 81, 1)
	obj.draw = function(obj)
		l = ": "..tostring(lives)
		screen.drawText(obj.x + 78 - #l, obj.y, 0x000000, l)
		screen.drawText(obj.x + 77 - #l, obj.y, 0xFF0000, "♥")
	end
	return obj
end

local function dynamicText(x, y, text, mode)
	local obj = GUI.object(x, y, 81, 1)
	obj.draw = function(obj)
		screen.drawText(obj.x, obj.y, 0x000000, text..(mode and hiscor or scor))
	end
	return obj
end



local currentScriptPath = fs.path(system.getCurrentScript())

local localization = system.getLocalization(currentScriptPath.."Localizations/")
local keyb = localization.keyboard
local wordsdb = fs.readTable(currentScriptPath.."Localizations/"..system.getUserSettings().localizationLanguage..'.wdb')


if not fs.exists(currentScriptPath.."Hiscores.scf") then
	hiscores = {[playUser] = 0}
	fs.writeTable(currentScriptPath.."Hiscores.scf", hiscores)
else
	hiscores = fs.readTable(currentScriptPath.."Hiscores.scf")
end


local howto = window:addChild(GUI.textBox(1, math.floor(#localization.howToText/2)-3, 81, #localization.howToText, 
	0xFFFFFF, 0x2D2D2D, localization.howToText))
howto:setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_CENTER)
howto.hidden = true
local hwbut = window:addChild(GUI.button(26, #localization.howToText+7, 30, 3, 0x878787, 0xFFFFFF, 0x880000, 0x555555, localization.back))
hwbut.hidden = true


local diffscr = window:addChild(GUI.container(1, 1, 81, 30))
diffscr.hidden = true
diffscr:addChild(GUI.text(41 - math.floor(ulen(localization.selDiff)/2), 4, 0x878787, localization.selDiff))


local gscr = window:addChild(GUI.container(1, 1, 81, 30))
gscr.hidden = true
local keybLay = gscr:addChild(GUI.layout(1, 15, 81, 12, 1, 3))
keybLay:setDirection(1, 1, GUI.DIRECTION_HORIZONTAL)
keybLay:setDirection(1, 2, GUI.DIRECTION_HORIZONTAL)
keybLay:setDirection(1, 3, GUI.DIRECTION_HORIZONTAL)

local function resetKeyb()
	for _, v in pairs(keybLay.children) do
		v.disabled = false
	end
end



gscr:addChild(dynamicText(3, 3, localization.scores, false))
gscr:addChild(dynamicText(3, 5, localization.record, true))
gscr:addChild(GUI.text(79 - ulen(localization.player..playUser), 3, 0x000000, localization.player..playUser))
gscr:addChild(livesText())
local gamex = gscr:addChild(GUI.button(27, 27, 29, 3, 0x878787, 0xFFFFFF, 0x880000, 0x555555, localization.exit))
local defText = gscr:addChild(GUI.text(1, 7, 0x000000, ""))
local wordsLay = gscr:addChild(GUI.layout(1, 9, 81, 3, 1, 1))
wordsLay:setDirection(1, 1, GUI.DIRECTION_HORIZONTAL)
--[[
local d = wordsLay:addChild(letterForLay('П'))
d.showLetter = true
local d = wordsLay:addChild(letterForLay('И'))
d.showLetter = true
wordsLay:addChild(letterForLay('З'))
local d = wordsLay:addChild(letterForLay('Д'))
d.showLetter = true
wordsLay:addChild(letterForLay('А'))
keybLay.children[5].colors.disabled.background = 0xFF0000
keybLay.children[5].disabled = true
keybLay.children[15].colors.disabled.background = 0xFF0000
keybLay.children[15].disabled = true
keybLay.children[3].colors.disabled.background = 0xFF0000
keybLay.children[3].disabled = true
keybLay.children[9].colors.disabled.background = 0xFF0000
keybLay.children[9].disabled = true
lives = 5
scor = 50
hiscor = 1220
--]]


local function nextWord()
	while lastnum == num do
		num = math.random(1, #wordsdb)
	end
	defText.localX = 41 - math.floor(ulen(wordsdb[num].title)/2)
	defText.text = wordsdb[num].title
	wordsLay:removeChildren()
	for _, v in pairs(wordsdb[num].word) do
		wordsLay:addChild(letterForLay(uup(v)))
	end
	resetKeyb()
	lastnum = num
end

local function writeScore()
	if not hiscores[playUser] or scor > hiscor then hiscores[playUser] = scor end
	fs.writeTable(currentScriptPath.."Hiscores.scf", hiscores)
end

local function startGame()
	math.randomseed(os.time())
	lives = (diff == 1 or diff == 4) and 10 or diff == 2 and 5 or 2
	scor = 0
	hiscor = hiscores[playUser] or 0
	nextWord()
	startd = true
end

local function stopGame()
	defText.localX = 41 - math.floor(ulen(localization.gameOver)/2)
	defText.text = localization.gameOver
	startd = false
end

local function processKey(obj)
	local found = 0
	for _, v in pairs(wordsLay.children) do
		if v.letter == obj.text then
			v.showLetter = true
			found = found + 1
		end
	end
	if found == 0 then
		obj.colors.disabled.background = 0xFF0000
		lives = lives - 1
		combo = 1
		if lives == 0 then
			obj.disabled = true
			stopGame()
			return
		end
	else
		obj.colors.disabled.background = 0x00FF00
		scor = scor + (combo * (diff == 1 and 2 or diff == 2 and 10 or diff == 3 and 50 or 100) * found)
		combo = combo + found
		local solved = true
		for _, v in pairs(wordsLay.children) do
			if not v.showLetter then solved = false break end
		end
		if solved then
			lives = diff == 1 and lives + 2 or (diff == 2 or diff == 3) and lives + 1 or lives
			defText.localX = 41 - math.floor(ulen(localization.solved)/2)
			defText.text = localization.solved
			gamex.text = localization.next
			oldtouch = gamex.onTouch
			startd = false
			gamex.onTouch = function()
				nextWord()
				gamex.onTouch = oldtouch
				gamex.text = localization.exit
				startd = true
			end
		end
	end
	obj.disabled = true
end


local reclab = window:addChild(GUI.text(41 - math.floor(ulen(localization.records..':')/2), 3, 0x000000, localization.records..':'))
reclab.hidden = true
local reclist = window:addChild(GUI.textBox(3, 5, 77, 19, 0xD2D2D2, 0x2D2D2D, {}, 1, 1, 1))
reclist.hidden = true
reclist:setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_CENTER)
local rcbut = window:addChild(GUI.button(26, 26, 30, 3, 0x878787, 0xFFFFFF, 0x880000, 0x555555, localization.back))
rcbut.hidden = true


local function mkDiffBut(parent, y, text, desc, difflvl)
	parent:addChild(GUI.text(41 - math.floor(ulen(desc)/2), y, 0x000000, desc))
	parent:addChild(GUI.button(26, y+2, 30, 1, 0x878787, 0xFFFFFF, 0x880000, 0x555555, text)).onTouch = function()
		diff = difflvl
		diffscr.hidden = true
		startGame()
		gscr.hidden = false
	end
end

mkDiffBut(diffscr, 7, localization.hardcore, localization.hardcoreDesc, 4)
mkDiffBut(diffscr, 12, localization.hard, localization.hardDesc, 3)
mkDiffBut(diffscr, 17, localization.medium, localization.mediumDesc, 2)
mkDiffBut(diffscr, 22, localization.easy, localization.easyDesc, 1)


local mmenu = window:addChild(GUI.container(1, 1, 81, 30))
mmenu:addChild(GUI.image(6, 3, image.load(currentScriptPath.."Logo.pic")))

mmenu:addChild(GUI.text(63, 9, 0x878787, "for MineOS"))
mmenu:addChild(GUI.text(17, 28, 0x878787, "GuessWord for MineOS (c) Compys S&N Systems [2021]"))
mmenu:addChild(GUI.text(28, 29, 0x878787, "GuessWord (c) newbie [2016]"))

mmenu:addChild(GUI.button(26, 13, 30, 3, 0x878787, 0xFFFFFF, 0x880000, 0x555555, localization.newGame)).onTouch = function()
	mmenu.hidden = true
	diffscr.hidden = false
end


mmenu:addChild(GUI.button(26, 17, 30, 3, 0x878787, 0xFFFFFF, 0x880000, 0x555555, localization.records)).onTouch = function()
	local actualrec = {}
	for k, v in pairs(hiscores) do
		table.insert(actualrec, k..(" "):rep(40-#k-#tostring(v))..v)
	end
	reclist.lines = actualrec
	mmenu.hidden = true
	reclab.hidden = false
	reclist.hidden = false
	rcbut.hidden = false
end


mmenu:addChild(GUI.button(26, 21, 30, 3, 0x878787, 0xFFFFFF, 0x880000, 0x555555, localization.howToPlay)).onTouch = function()
	mmenu.hidden = true
	howto.hidden = false
	hwbut.hidden = false
end


hwbut.onTouch = function()
	howto.hidden = true
	hwbut.hidden = true
	mmenu.hidden = false
end

rcbut.onTouch = function()
	reclab.hidden = true
	reclist.hidden = true
	rcbut.hidden = true
	mmenu.hidden = false
end

diffscr:addChild(GUI.button(5, 27, 30, 3, 0x878787, 0xFFFFFF, 0x880000, 0x555555, localization.back)).onTouch = function()
	diffscr.hidden = true
	mmenu.hidden = false
end

gamex.onTouch = function()
	gscr.hidden = true
	startd = false
	writeScore()
	mmenu.hidden = false
end


for y = 1, #keyb do
	for x = 1, #keyb[y] do
		local but = keybLay:addChild(GUI.button(1, 1, 5, 3, 0x878787, 0xFFFFFF, 0xD2D2D2, 0x555555, keyb[y][x]))
		but.colors.disabled.text = 0xFFFFFF
		but.onTouch = function(_, obj)
			if startd then processKey(obj) end
		end
		if y > 1 then keybLay:setPosition(1, y, but) end
	end
end


keybLay.eventHandler = function(_, _, typ, _ , charnum)
	if typ == "key_down" and startd then
		sym = uup(uchar(charnum))
		for _, v in pairs(keybLay.children) do
			if v.text == sym then
				if not v.disabled and startd then processKey(v) end
				return
			end
		end
	end
end

---------------------------------------------------------------------------------

if not wordsdb then
	GUI.alert("Sorry, but there is no words database for your language!")
	window:remove()
end

workspace:draw()
