local GUI = require("GUI")
local fs = require("filesystem")
local tfat = require("TapFAT")
local system = require("system")
local component = require("component")

local locale = system.getCurrentScriptLocalization()
local servicePath = fs.path(system.getCurrentScript())..'TapFATService.lua'
local settingsPath = fs.path(system.getCurrentScript())..'Settings.cfg'

if not fs.exists(settingsPath) then
	fs.writeTable(settingsPath, {})
end
local sets = fs.readTable(settingsPath) or {}

if not component.isAvailable("tape_drive") then
	GUI.alert(locale.noStreamer)
	return
end
local ismnt, tape, driveAddr = false

local uSet, isAut, aWrk, sTsk = system.getUserSettings(), false, true
for _, tsk in pairs(uSet.tasks) do
	if tsk.path == servicePath then
		isAut = true
		if not tsk.enabled then aWrk = false sTsk = tsk end
		break
	end
end

local workspace, window, menu = system.addWindow(GUI.titledWindow(1, 1, 65, 25, "TapFAT Configurator"))
window.backgroundPanel.colors.transparency = 0.1
window.actionButtons.maximize.hidden = true

local selectr = window:addChild(GUI.layout(1, 1, window.width, window.height+1, 1, 1))
local main = window:addChild(GUI.container(1, 1, window.width, window.height))
main.hidden = true
local stat = main:addChild(GUI.text(3, 4, 0x4B4B4B, ''))

local function formatSize(size)
  local sizes = {"b", "Kb", "Mb", "Gb"}
  local unit = 1
  while size > 1024 and unit < #sizes do
    unit = unit + 1
    size = size / 1024
  end
  return math.floor(size * 10) / 10 .. sizes[unit]
end

if not isAut then
	selectr.hidden = true
	local dialog = window:addChild(GUI.titledWindow(12, 8, 44, 10, "TapFAT Service"))
	dialog.actionButtons.hidden = true
	local diLa = dialog:addChild(GUI.layout(1, 1, dialog.width, dialog.height-2, 1, 1))
	diLa:setSpacing(1, 1, 0)
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noService))
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noService2))
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noService3))
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noService4))
	dialog:addChild(GUI.roundedButton(8, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.yes)).onTouch = function()
		table.insert(uSet.tasks, {enabled = true, path = servicePath, mode = 1})
		system.saveUserSettings()
		dialog:remove()
		selectr.hidden = false
	end
	dialog:addChild(GUI.roundedButton(28, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.no)).onTouch = function()
		dialog:remove()
		selectr.hidden = false
	end
elseif not aWrk then
	selectr.hidden = true
	local dialog = window:addChild(GUI.titledWindow(12, 8, 44, 10, "TapFAT Service"))
	dialog.actionButtons.hidden = true
	local diLa = dialog:addChild(GUI.layout(1, 1, dialog.width, dialog.height-2, 1, 1))
	diLa:setSpacing(1, 1, 0)
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noServiceB))
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noService2))
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noService3))
	diLa:addChild(GUI.text(1, 1, 0x4B4B4B, locale.noService4B))
	dialog:addChild(GUI.roundedButton(8, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.yes)).onTouch = function()
		sTsk.enabled = true
		system.saveUserSettings()
		dialog:remove()
		selectr.hidden = false
	end
	dialog:addChild(GUI.roundedButton(28, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.no)).onTouch = function()
		dialog:remove()
		selectr.hidden = false
	end
end 

local autoMnt = main:addChild(GUI.switchAndLabel(3, 7, 25, 5, 0x66DB80, 0x1D1D1D, 0xA4A4A4, 0x4B4B4B, locale.autoMount, false))

main:addChild(GUI.text(3, 11, 0x4B4B4B, locale.compTab))
local comTab = main:addChild(GUI.comboBox(46, 11, 17, 1, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888))
comTab:addItem("LZSS")
comTab:addItem(locale.datCard)
comTab:addItem(locale.no)

main:addChild(GUI.text(3, 13, 0x4B4B4B, locale.saveDate))
local sDat = main:addChild(GUI.comboBox(46, 13, 17, 1, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888))
sDat:addItem(locale.yes)
sDat:addItem(locale.no)
local function addButton(x, y, text, obj)
  return obj:addChild(GUI.roundedButton(x, y, 25, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, text))
end

local function addBigButton(x, y, text, obj)
  return obj:addChild(GUI.roundedButton(x, y, 15, 3, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, text))
end

selectr:addChild(GUI.text(1, 1, 0x4B4B4B, locale.selDrive))
local tapLst = selectr:addChild(GUI.list(1, 1, 50, 18, 1, 0, 0xB4B4B4, 0x4B4B4B, 0xD2D2D2, 0x4B4B4B, 0x3366CC, 0xFFFFFF, false))
for addr in component.list("tape_drive") do
	tapLst:addItem(addr)
end

addButton(6, 24, locale.goBack, main).onTouch = function()
	if not component.isAvailable("tape_drive") then
		window:remove()
		GUI.alert(locale.noStreamer)
		return
	end
	tapLst:removeChildren()
	for addr in component.list("tape_drive") do
		tapLst:addItem(addr)
	end
	if #tapLst.children < tapLst.selectedItem then tapLst.selectedItem = #tapLst.children end
	selectr.hidden = false
	main.hidden = true
end

addButton(36, 24, locale.save, main).onTouch = function()
	local par1, par2 = comTab.selectedItem ~= 3 and comTab.selectedItem or false, sDat.selectedItem == 1 and true or false
	tape.setDriveProperty('tabcom', par1)
	tape.setDriveProperty('stordate', par2)
	if not sets[driveAddr] then sets[driveAddr] = {} end
	sets[driveAddr].tCom = par1
	sets[driveAddr].sDate = par2
	sets[driveAddr].autoMnt = autoMnt.switch.state
	fs.writeTable(settingsPath, sets)
end

local moUmo = addBigButton(31, 3, '', main)
moUmo.onTouch = function()
	if not ismnt then
		fs.mount(tape, '/Mounts/'..tape.address..'/')
		ismnt = true
		moUmo.text = locale.unmount
		stat.text = locale.status..locale.cMounted
	else
		fs.unmount(tape.address)
		ismnt = false
		moUmo.text = locale.mount
		stat.text = locale.status..locale.cNot..' '..locale.cMounted
	end
end

addBigButton(48, 3, locale.chLab, main).onTouch = function()
	if not tape.isReady() then GUI.alert(locale.noTapeInsert) return end
	main.hidden = true
	local dialog = window:addChild(GUI.titledWindow(13, 9, 40, 8, locale.labDlg))
	dialog.actionButtons.hidden = true
	local inp = dialog:addChild(GUI.input(6, 3, 30, 3, 0xE1E1E1, 0x5A5A5A, 0x999999, 0xFFFFFF, 0x2D2D2D, tape.getLabel(), locale.tapLab))
	dialog:addChild(GUI.roundedButton(7, 7, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.ok)).onTouch = function()
		local res, why = tape.setLabel(inp.text)
		if not res then GUI.alert(locale.error..": "..why) end
		dialog:remove()
		main.hidden = false
	end
	dialog:addChild(GUI.roundedButton(25, 7, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.cancel)).onTouch = function()
		dialog:remove()
		main.hidden = false
	end
end

addBigButton(31, 6, locale.format, main).onTouch = function()
	if not tape.isReady() then GUI.alert(locale.noTapeInsert) return end
	main.hidden = true
	local dialog = window:addChild(GUI.titledWindow(13, 9, 40, 8, locale.formType))
	dialog.actionButtons.hidden = true
	dialog:addChild(GUI.roundedButton(6, 3, 30, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.formFull)).onTouch = function()
		dialog:remove()
		local dialog = window:addChild(GUI.titledWindow(12, 8, 44, 10, locale.youSure))
		dialog.actionButtons.hidden = true
		local diLa = dialog:addChild(GUI.layout(1, 1, dialog.width, dialog.height-2, 1, 1))
		diLa:setSpacing(1, 1, 0)
		diLa:addChild(GUI.text(1, 1, 0x990000, locale.dFormat))
		diLa:addChild(GUI.text(1, 1, 0x990000, locale.dFormat2))
		diLa:addChild(GUI.text(1, 1, 0x990000, locale.dFormat3))
		dialog:addChild(GUI.roundedButton(8, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.yes)).onTouch = function()
			diLa:removeChildren()
			dialog:removeChildren(5)
			dialog.titleLabel.text = locale.formCapt
			diLa.height = dialog.height+1
			diLa:addChild(GUI.text(1, 1, 0x990000, locale.formatting))
			diLa:addChild(GUI.text(1, 1, 0x990000, locale.formatting2))
			diLa:addChild(GUI.text(1, 1, 0x990000, locale.formatting3))
			workspace:draw()
			tape.format()
			dialog:remove()
			main.hidden = false
		end
		dialog:addChild(GUI.roundedButton(28, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.no)).onTouch = function()
			dialog:remove()
			main.hidden = false
		end
	end
	dialog:addChild(GUI.roundedButton(6, 5, 30, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.formQuick)).onTouch = function()
		dialog:remove()
		local dialog = window:addChild(GUI.titledWindow(12, 8, 44, 10, locale.youSure))
		dialog.actionButtons.hidden = true
		local diLa = dialog:addChild(GUI.layout(1, 1, dialog.width, dialog.height-2, 1, 1))
		diLa:setSpacing(1, 1, 0)
		diLa:addChild(GUI.text(1, 1, 0x990000, locale.dFormat))
		diLa:addChild(GUI.text(1, 1, 0x990000, locale.dFormat2B))
		diLa:addChild(GUI.text(1, 1, 0x990000, locale.dFormat3))
		dialog:addChild(GUI.roundedButton(8, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.yes)).onTouch = function()
			tape.format(true)
			dialog:remove()
			main.hidden = false
		end
		dialog:addChild(GUI.roundedButton(28, 9, 10, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.no)).onTouch = function()
			dialog:remove()
			main.hidden = false
		end
	end
	dialog:addChild(GUI.roundedButton(6, 7, 30, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.cancel)).onTouch = function()
		dialog:remove()
		main.hidden = false
	end
end

addBigButton(48, 6, locale.tapInfo, main).onTouch = function()
	if not tape.isReady() then GUI.alert(locale.noTapeInsert) return end
	local tb, rs = tape.getTable()
	if not tb then GUI.alert(locale.error..": "..rs..". "..locale.tableErr) return end
	main.hidden = true
	local dialog = window:addChild(GUI.titledWindow(13, 9, 40, 10, locale.tapInfo))
	dialog.actionButtons.hidden = true
	local spacUs, spacTo = tape.spaceUsed(), tape.spaceTotal()
	dialog:addChild(GUI.text(3, 3, 0x4B4B4B, locale.label..(tape.getLabel() == '' and locale.noLabel or tape.getLabel())))
	dialog:addChild(GUI.text(3, 4, 0x4B4B4B, locale.tapType..math.ceil((spacTo+8192)/245760)..' Min'))
	dialog:addChild(GUI.text(3, 5, 0x4B4B4B, locale.effSize..formatSize(spacTo)))
	dialog:addChild(GUI.text(3, 6, 0x4B4B4B, locale.free..formatSize(spacTo-spacUs)..' ('..100-math.ceil((spacUs/spacTo * 100))..'%)'))
	dialog:addChild(GUI.roundedButton(6, 9, 30, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, locale.ok)).onTouch = function()
		dialog:remove()
		main.hidden = false
	end
end

addButton(1, 1, locale.goConf, selectr).onTouch = function()
	selectr.hidden = true
	main.hidden = false
	driveAddr = tapLst:getItem(tapLst.selectedItem).text
	ismnt = false
	for fss in fs.mounts() do
		if driveAddr == fss.driveAddress then ismnt = true tape = fss break end
	end
	if not ismnt then
		tape = tfat.proxy(driveAddr)
		if sets[driveAddr] then
			tape.setDriveProperty('tabcom', sets[driveAddr].tCom)
			tape.setDriveProperty('stordate', sets[driveAddr].sDate)
		end
	end
	if sets[driveAddr] then
		autoMnt.switch:setState(sets[driveAddr].autoMnt)
	else
		autoMnt.switch:setState(false)
	end
	local cSt = tape.getDriveProperty('tabcom')
	comTab.selectedItem = cSt == false and 3 or cSt
	local dSt = tape.getDriveProperty('stordate')
	sDat.selectedItem = dSt and 1 or 2
	stat.text = locale.status..(ismnt and locale.cMounted or locale.cNot..' '..locale.cMounted)
	moUmo.text = ismnt and locale.unmount or locale.mount
end

workspace:draw()
