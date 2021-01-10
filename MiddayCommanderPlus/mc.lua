--[[               Midday Commander Plus Ver. 1.2a ]]--
--[[         Original by Zer0Galaxy & Neo & Totoro ]]--
--[[                        Plus version by Bs()Dd ]]--
--[[ 2015-2016, 2020-2021  (c)  No rights reserved ]]--

local VER = '1.2a'

local unicode = require('unicode')
local len=unicode.len
local sub=unicode.sub
local fs = require('filesystem')
local term = require('term')
local shell = require('shell')
local event = require('event')
local com = require('component')
local pc = require('computer')
local gpu = com.gpu
local keyboard = require('keyboard')
local seriz = require('serialization')

local configPath = "/etc/mc.cfg"

local function LoadTable(path, name)
  local unseriz
  local file, why = io.open(path, 'r')
  if file == nil then
    print("Can't open "..name.." file: "..(why or "unknown reason"))
    os.exit()
  else
    local rawdata = file:read(fs.size(path))
    unseriz, why = seriz.unserialize(rawdata)
    if unseriz == nil then
      print("Incorrect "..name.." file: "..(why or "unknown reason"))
      os.exit()
    end
  end
  return unseriz
end

local config = LoadTable(configPath, 'config')
local locale = LoadTable(config.LocaleFile, 'locale')
local theme

local keys = keyboard.keys
local Left,Rght,Active,Find
local wScr, hScr = gpu.maxResolution()
local cmd, scr, Menu
local NormalCl, PanelCl, DirCl, SelectCl, WindowCl, AlarmWinCl
local xMenu,cmdstr,curpos,work=-1,'',0,true
local Shift,Ctrl,Alt=256,512,1024
local lastClick=0

if wScr>50 then
  theme = LoadTable(config.ThemeFile, 'theme')
end

local helpt
  if wScr<80 then
    helpt = locale.Help.HelpText
  else
    helpt = locale.Help.Header
    helpt[2] = helpt[2]..VER
    helpt[#helpt+1] = ''
    for i=1,#locale.Help.HelpText do
        helpt[#helpt+1] = locale.Help.HelpText[i]
    end
  end
helpt.left = true

local function SetColor(cl)
  gpu.setForeground(cl[1])
  gpu.setBackground(cl[2])
end

local function saveScreen()
  scr={cl={}}
  scr.W,scr.H = gpu.getResolution()
  scr.cl[1]=gpu.getForeground()
  scr.cl[2]=gpu.getBackground()
  scr.posX, scr.posY = term.getCursor()
  for i=1,scr.H do
    scr[i]={}
    local FC,BC
    for j=1,scr.W do
      local c,fc,bc=gpu.get(j,i)
      if fc==FC then fc=nil end
      if bc==BC then bc=nil end
      if fc or bc then
          table.insert(scr[i],{fc=fc,bc=bc,c=""})
        FC,BC=fc or FC, bc or BC
      end
      scr[i][#scr[i]].c=scr[i][#scr[i]].c .. c
    end
  end
  gpu.setResolution(wScr,hScr)
end

local function loadScreen()
  gpu.setResolution(scr.W,scr.H)
  term.setCursorBlink(false)
  for i=1,scr.H do
    local curX=1
    for j=1,#scr[i] do
      if scr[i][j].fc then gpu.setForeground(scr[i][j].fc) end
      if scr[i][j].bc then gpu.setBackground(scr[i][j].bc) end
      gpu.set(curX,i,scr[i][j].c) curX=curX+len(scr[i][j].c)
    end
  end
  SetColor(scr.cl)
  term.setCursor(scr.posX,scr.posY)
  term.setCursorBlink(true)
end

local function ShowCmd()
  SetColor(NormalCl)
  term.setCursor(1, hScr-1)
  term.clearLine()
  term.write(shell.getWorkingDirectory()..'> '..cmdstr)
  term.setCursor(term.getCursor()-curpos, hScr-1)
end

local panel ={wPan=math.ceil(wScr / 2)}
function panel:ShowFirst()
  local p=self.Path..'/'
  if len(p)> self.wPan-6 then p='..'..sub(p,-self.wPan+7) end
  p=' '..p..' '
  gpu.set(self.X, 1,'┌'..string.rep('─',self.wPan-2)..'┐')
  term.setCursor(self.X+(self.wPan-len(p))/2,1)
  if self==Active then
    SetColor(SelectCl)
    term.write(p)
    SetColor(PanelCl)
  else
    term.write(p)
  end
end

function panel:ShowLine(Line)
  term.setCursor(self.X, Line-self.Shift+2)
  term.write('│')
  if self.tFiles[Line]~=nil then
    local Name=self.tFiles[Line]
    if self.tSize[Line]==locale.DIR then Name='/'..Name SetColor(DirCl) end
    if len(Name)>self.wPan-4 then Name=sub(Name,1,self.wPan-6)..'..' end
    Name=' '..Name..string.rep(' ',self.wPan-len(Name)-4)..' '
    if self==Active and Line==self.CurLine then SetColor(SelectCl) end
    term.write(Name)
  else
    term.write(string.rep(' ',self.wPan-2))
  end
  SetColor(PanelCl)
  term.write('│')
end

function panel:ShowLines()
  for i=self.Shift, self.Shift+hScr-5 do self:ShowLine(i) end
end

function panel:ShowLast()
  gpu.set(self.X, hScr-2,'└'..string.rep('─',self.wPan-2)..'┘')
  gpu.set(self.X+2, hScr-2, self.tSize[self.CurLine])
end

function panel:Show()
  if self.CurLine>#self.tFiles then self.CurLine=#self.tFiles end
  SetColor(PanelCl)
  self:ShowFirst()
  self:ShowLines()
  self:ShowLast()
end

function panel:GetFiles()
  local Files={}
  for name in fs.list(self.Path) do
    table.insert(Files, name)
  end
  if self.Path=='' then
    self.tFiles={}
    self.tSize={}
  else
    self.tFiles={'..'}
    self.tSize={locale.DIR}
  end
  for n,Item in pairs(Files) do
    if Item:sub(-1) == '/' then
      table.insert(self.tFiles,Item)
      table.insert(self.tSize,locale.DIR)
    end
  end
  for n,Item in pairs(Files) do
    if Item:sub(-1) ~= '/' then
      local sPath=fs.concat(self.Path,Item)
      table.insert(self.tFiles,Item)
      table.insert(self.tSize,fs.size(sPath)..locale.Bytes)
    end
  end
  self:Show()
end

function panel:SetPos(FileName)
  if fs.isDirectory(FileName) then FileName=FileName..'/' end
  self.Path,FileName=FileName:match('(.-)/?([^/]+/?)$')
  shell.setWorkingDirectory(self.Path)
  self.CurLine=1
  self.Shift=1
  self:GetFiles()
  for i=1,#self.tFiles do
    if self.tFiles[i]==FileName then
      self.CurLine=i
      break
    end
  end
  if Active.CurLine>hScr-4 then
    Active.Shift=Active.CurLine-hScr+6
  end
end

function panel:new(x,path)
  local obj={X = x, Path =path, tFiles={}, tSize={}, CurLine=1, Shift=1}
  return setmetatable(obj,{__index=panel})
end

local Fpanel ={wPan=wScr}
setmetatable(Fpanel,{__index=panel})

function Fpanel:new(x,path)
  local obj=panel:new(x,path)
  return setmetatable(obj,{__index=Fpanel})
end

local function FindFile(FileName,Path)
  local Result={}
  local SubDir={}
  for name in fs.list(Path) do
    if string.sub(name, -1) == '/' then
      table.insert(SubDir, Path..name)
      name=name..".."
    end
    if string.match(name, FileName) then
      table.insert(Result, Path..name)
    end
  end
  for i=1,#SubDir do
    local Files = FindFile(FileName,SubDir[i])
    for j=1,#Files do table.insert(Result,Files[j]) end
  end
  return Result
end

function Fpanel:GetFiles()
  local code={{'%.','%%.'},{'*','.-'},{'?','.'}}
  local Templ=self.Path
  for i=1,#code do Templ=Templ:gsub(code[i][1],code[i][2]) end
  self.tFiles=FindFile('^'..Templ..'$','')
  table.insert(self.tFiles,1,'..')
  self.tSize={locale.DIR}
  for i=2,#self.tFiles do
    if fs.isDirectory(self.tFiles[i]) then
      self.tSize[i]=locale.DIR
    else
      self.tSize[i]=tostring(fs.size(self.tFiles[i]))
    end
  end
  self:Show()
end

function Fpanel:ShowFirst()
  local p=locale.FindRes..self.Path
  if len(p)> self.wPan-6 then p='..'..sub(p,-self.wPan+7) end
  p=' '..p..' '
  gpu.set(self.X, 1,'┌'..string.rep('─',self.wPan-2)..'┐')
  SetColor(SelectCl)
  gpu.set(self.X+(self.wPan-len(p))/2,1,p)
  SetColor(PanelCl)
end

local function ShowPanels()
  SetColor(NormalCl)
  term.clear()
  if Active==Find then
    Find:Show()
  else
    Left:GetFiles()
    Rght:GetFiles()
  end
  term.setCursor(xMenu, hScr)
  for i=1,#Menu do
    if #Menu[i]>0 then
      SetColor(NormalCl)
      term.write(' F'..i)
      SetColor(SelectCl)
      term.write(Menu[i])
    end
  end
  term.setCursorBlink(true)
end

local function Dialog(cl,Lines,Str,But)
  SetColor(cl)
  local H=#Lines+3
  local CurBut=1
  if Str then H=H+1 CurBut=0 end
  if not But then But={locale.AltOk} end
  local function Buttons()
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
  for i=1,#Lines do
    if len(Lines[i])>W then W=len(Lines[i]) end
  end
  if Str and (len(Str)>W) then W=len(Str) end
  W=W+4
  local x= math.ceil((wScr-W)/2)
  local y= math.ceil((hScr-H)/2)+1
  gpu.set(x-1, y, ' ╔'..string.rep('═',W-2)..'╗ ')
  local dept = gpu.getDepth()
  local dlgLen = W+2
  for i=1,#Lines+2 do
    gpu.set(x-1, y+i, ' ║'..string.rep(' ',W-2)..'║ ')
    if dept > 1 then 
      local sym = gpu.get(x-1+dlgLen, y+i)
      local sym2 = gpu.get(x+dlgLen, y+i)
      SetColor({0xCCCCCC, 0x000000})
      gpu.set(x-1+dlgLen, y+i, sym)
      gpu.set(x+dlgLen, y+i, sym2)
      SetColor(cl)
    end
  end
  gpu.set(x-1, y+H-1,' ╚'..string.rep('═',W-2)..'╝ ')
  if dept > 1 then
    local sym = gpu.get(x-1+dlgLen, y+H-1)
    local sym2 = gpu.get(x+dlgLen, y+H-1)
    SetColor({0xCCCCCC, 0x000000})
    gpu.set(x-1+dlgLen, y+H-1, sym)
    gpu.set(x+dlgLen, y+H-1, sym2)
    for i=1, dlgLen do
      local sym = gpu.get(x+i,y+H)
      gpu.set(x+i,y+H, sym)
    end
    SetColor(cl)
  end
  for i=1,#Lines do
    if Lines.left then gpu.set(x+2, y+i, Lines[i])
    else gpu.set(x+(W-len(Lines[i]))/2, y+i, Lines[i]) end
  end
  local mButtons = {}
  local Butt=''
  local ButtX = math.floor(x+(W-len(Buttons()))/2)
  for i=1,#But do
    table.insert(mButtons, {len(Butt)+ButtX-1, len(Butt..' '..But[i]..' ')+ButtX, But[i]})
    Butt=Butt..' '..But[i]..' '
  end
  while true do
    term.setCursor(x+(W-len(Buttons()))/2, y+H-2)
    term.write(Buttons())
    if CurBut==0 then
      SetColor({0xFFFFFF, 0x333333})
      local S=Str
      if len(S)>W-4 then S='..'..sub(S,-W+6) end
      gpu.set(x+2, y+H-3, string.rep(' ',W-4))
      term.setCursor(x+2, y+H-3)  term.write(S)
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
      elseif code == keys.left and CurBut~=0 then
        if CurBut>1 then CurBut=CurBut-1 end
      elseif code == keys.right and CurBut~=0 then
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

local function call(func,...)
  local r,e=func(...)
  if not r then Dialog(AlarmWinCl,{e}) end
  return r
end

local function CpMv(func,from,to)
  if fs.isDirectory(from) then
    if not fs.exists(to) then call(fs.makeDirectory,to)  end
    for name in fs.list(from) do
      CpMv(func,fs.concat(from,name),fs.concat(to,name))
    end
    if func==fs.rename then call(fs.remove,from) end
  else
    if fs.exists(to) then
      if Dialog(AlarmWinCl,{locale.FileExists,to,locale.Overwrite},nil,{locale.Yes,locale.No})==locale.Yes then
        if not call(fs.remove,to) then return end
      end
    end
    call(func,from,to)
  end
end

local function CopyMove(action,func)
  if Active==Find then return end
  Name = ((Active==Rght) and Left or Rght).Path..'/'..cmd
  cmd=Active.Path..'/'..cmd
  local Ok,Name=Dialog(WindowCl,{action,cmd,locale.To},Name,{locale.Ok,locale.Cancel})
  if Ok==locale.Ok then
    if cmd:sub(-2) == '..' then
      Dialog(AlarmWinCl,{locale.CpParDir})
    elseif cmd==Name then
      Dialog(AlarmWinCl,{locale.ToItself})
    else
      CpMv(func, cmd, Name)
    end
  end
  ShowPanels()
end

local eventKey={}
eventKey[keys.up]=function()
  if Active.CurLine>1 then
    local Line=Active.CurLine
    Active.CurLine=Line-1
    if Active.CurLine<Active.Shift then
      Active.Shift=Active.CurLine
      Active:ShowLines()
    else
      Active:ShowLine(Active.CurLine)
      Active:ShowLine(Line)
    end
    Active:ShowLast()
  end
end

eventKey[keys.down]=function()
  if Active.CurLine<#Active.tFiles then
    local Line=Active.CurLine
    Active.CurLine=Active.CurLine+1
    if Active.CurLine>Active.Shift+hScr-5 then
      Active.Shift=Active.CurLine-hScr+5
      Active:ShowLines()
    else
      Active:ShowLine(Active.CurLine)
      Active:ShowLine(Line)
    end
    Active:ShowLast()
  end
end

eventKey[keys.left]=function()
  if curpos<len(cmdstr) then curpos=curpos+1 end
end

eventKey[keys.right]=function()
  if curpos>0 then curpos=curpos-1 end
end

eventKey[keys.tab]=function(noShow)
  if Active==Find then return end
  Active = (Active==Rght) and Left or Rght
  shell.setWorkingDirectory(Active.Path)
  if not noShow then ShowPanels() end
end

eventKey[keys.enter]=function()
  local function exec(cmd, fromstr)
    loadScreen() scr=nil
    if fromstr then shell.execute(cmd)
    elseif fs.name(cmd):match("(%.%w+)$")==nil then
      shell.execute(Active.Path..'/'..cmd)
    else
      local extLow = fs.name(cmd):match("(%.%w+)$"):lower()
      if config.Associations[extLow] ~= nil then
        shell.execute(config.Associations[extLow]..' '..cmd)
      else
        shell.execute(Active.Path..'/'..cmd)
      end
    end
    saveScreen()
    ShowPanels()
  end
  curpos=0
  if cmdstr~='' then
    exec(cmdstr, true)
    cmdstr=''
    return
  end
  if Active==Find then
    Active=Find.Last
    if cmd~='..' then Active:SetPos("/"..cmd) end
    ShowPanels()
    return
  end
  if Active.tSize[Active.CurLine]==locale.DIR then
    if cmd=='..' then  Active:SetPos(Active.Path)
    else  Active:SetPos(shell.resolve(cmd)..'/..')  end
    Active:Show()
  else
    exec(cmd)
  end
end

eventKey[Ctrl+keys.enter]=function()
  cmdstr=cmdstr..cmd..' '
end

eventKey[Alt+keys.enter]=function()
  loadScreen()
  event.pull("key_down")
  gpu.setResolution(wScr,hScr)
  ShowPanels()
end

eventKey[keys.back]=function()
  if cmdstr~='' then
    if curpos==0 then cmdstr=sub(cmdstr,1,-2)
    else cmdstr=sub(cmdstr,1,-2-curpos)..sub(cmdstr,-curpos)
    end
  end
end

eventKey[keys.delete]=function()
  if cmdstr~='' then
    if curpos>0 then
      curpos=curpos-1
      if curpos==0 then
        cmdstr=sub(cmdstr,1,-2)
      else
        cmdstr=sub(cmdstr,1,-2-curpos)..sub(cmdstr,-curpos)
      end
    end
  end
end

eventKey[keys['end']]=function() curpos=0 end

eventKey[keys.home]=function() curpos=len(cmdstr) end

eventKey[keys.f1]=function()
  if Active==Find then return end
  Dialog(SelectCl,helpt)
  ShowPanels()
end

eventKey[keys.f3]=function()
  if Active.tSize[Active.CurLine]==locale.DIR then
    Dialog(AlarmWinCl,{locale.Error, cmd, locale.IsNotFile})
  else
    SetColor(NormalCl)
    term.setCursorBlink(false)
    shell.execute(config.Editor..' '..cmd)
  end
  ShowPanels()
end

eventKey[Shift+keys.f3]=function()
  local Ok,Name=Dialog(WindowCl,{locale.FileName},'',{locale.Ok,locale.Cancel})
  if Ok==locale.Ok then
    if Name == '' then
      Dialog(AlarmWinCl,{locale.FileEmpty})
    else
      SetColor(NormalCl)
      shell.execute(config.Editor..' '..Name)
    end
  end
  ShowPanels()
end

eventKey[keys.f4]=function()
  CopyMove(locale.CopyFile,fs.copy)
end

eventKey[keys.f5]=function()
  CopyMove(locale.MoveFile,fs.rename)
end

eventKey[keys.f7]=function()
  if Active==Find then return end
  local Ok,Name=Dialog(WindowCl,{locale.DirName},'',{locale.Ok,locale.Cancel})
  if Ok==locale.Ok then
    if Name == '' then
      Dialog(AlarmWinCl,{locale.DirEmpty})
    elseif Name=='..' or Name=='/..' or fs.exists(shell.resolve(Name)) then
      ShowPanels()
      Dialog(AlarmWinCl,{locale.FileExists})
    else
      fs.makeDirectory(shell.resolve(Name))
    end
  end
  ShowPanels()
end

eventKey[Alt+keys.f7]=function()
  local Ok,Name=Dialog(WindowCl,{locale.Find,locale.FindChar1,locale.FindChar2},'',{locale.Ok,locale.Cancel})
  if Ok==locale.Ok then
    if Name == '' then
      Dialog(AlarmWinCl,{locale.FindEmpty})
      ShowPanels()
      return
    end
    Find.Path=Name
    Find.CurLine=1
    Find.Shift=1
    if Active~=Find then
      Find.Last=Active
      Active=Find
    end
    Find:GetFiles()
  end
  ShowPanels()
end

eventKey[keys.f8]=function()
  if Active==Find then return end
  if Dialog(AlarmWinCl,{locale.Delete, cmd..'?'}, nil, {locale.Yes,locale.No})==locale.Yes then
    call(fs.remove,shell.resolve(cmd))
  end
  ShowPanels()
end

eventKey[keys.f10]=function()
  if Dialog(WindowCl,{locale.Exit}, nil, {locale.Yes,locale.No})==locale.Yes then
    work=false
  else
    ShowPanels()
  end
end

local function eventTouch(tx,ty,mTouch)
  code = 0
  local panChang = false
  if keyboard.isShiftDown() then code=code+Shift end
  if keyboard.isControlDown() then code=code+Ctrl end
  if keyboard.isAltDown() then code=code+Alt end
  if ty<hScr-1 then
    if Active==Rght and tx<wScr/2+1 then eventKey[keys.tab](true) panChang = true
    elseif Active==Left and tx>wScr/2 then eventKey[keys.tab](true) panChang = true end
    SetColor(PanelCl)
  end
  if ty == hScr then
    for i=1, #mTouch do
      if tx>mTouch[i][1] and tx<mTouch[i][2] and eventKey[code+mTouch[i][3]]~=nil then 
        eventKey[code+mTouch[i][3]]() 
        return
      end
    end
  elseif ty>1 and ty<hScr-2 then
    if ty-1 == Active.CurLine and (code==0 or code==Ctrl) and
     not panChang and lastClick >= pc.uptime()-config.ClickDelay then
      if code==0 then cmdstr = '' end
      eventKey[code+keys.enter]()
    elseif ty-2<#Active.tFiles then
      local Line=Active.CurLine
      Active.CurLine=ty+Active.Shift-2
      Active:ShowLine(Active.CurLine)
      Active:ShowLine(Line)
      Active:ShowLast()   
    end
  end
  if panChang then ShowPanels() end
  lastClick = pc.uptime()
end

local function eventScroll(direction)
  if direction==1 then
    eventKey[keys.up]()
  elseif direction==-1 then
    eventKey[keys.down]()
  end
end

NormalCl={0xFFFFFF,0x000000}
if gpu.getDepth() > 1 then
  PanelCl=theme.Panels
  DirCl=theme.Dirs
  SelectCl=theme.Selected
  WindowCl=theme.Window
  AlarmWinCl=theme.AlarmWindow
else
  PanelCl=NormalCl
  DirCl=NormalCl
  SelectCl={0x000000,0xFFFFFF}
  WindowCl=NormalCl
  AlarmWinCl=NormalCl
end
if wScr<80 then
  Menu=locale.Menu
elseif wScr<160 then
  Menu=locale.MediumMenu
else
  Menu=locale.LargeMenu
end
for i=1,#Menu do
  if #Menu[i]>0 then xMenu=xMenu+#tostring(i)+len(Menu[i])+2 end
end
xMenu=math.floor((wScr-xMenu) / 2)
local mTouch = {}
table.insert(mTouch, {xMenu, xMenu+len(Menu[1])+3, 59})
j=2
for i=2,#Menu do
  if #Menu[i]>0 then table.insert(mTouch, 
                     {mTouch[j-1][2], mTouch[j-1][2]+2+len(Menu[i])+len(tostring(i)), 58+i}) j=j+1 end
end

local curwd =shell.getWorkingDirectory():sub(1,-1)~='/' and shell.getWorkingDirectory():sub(1,-1) or ''
Left =panel:new(1,'')
Rght =panel:new(Left.wPan+1,curwd)
Find =Fpanel:new(1,'')
Active =Rght

print('The Midday Commander Plus, Version '..VER)
print('Not Copyright (C) 2015-2016, 2020-2021 by Zer0Galaxy, Neo, Totoro & Bs()Dd')

saveScreen()
ShowPanels()
ShowCmd()
while work do
  local eventname, _, char, code, dir = term.pull()
  cmd=Active.tFiles[Active.CurLine]
  if eventname =='key_down' then
    if keyboard.isShiftDown() then code=code+Shift end
    if keyboard.isControlDown() then code=code+Ctrl end
    if keyboard.isAltDown() then code=code+Alt end
    if eventKey[code] ~= nil then
      SetColor(PanelCl)
      eventKey[code]()
      ShowCmd()
    elseif char > 0 then
      if curpos==0 then cmdstr=cmdstr..unicode.char(char)
      else cmdstr=cmdstr:sub(1,-1-curpos)..unicode.char(char)..cmdstr:sub(-curpos)
      end
      ShowCmd()
    end
  elseif eventname =='clipboard' then
    if char ~='' then
      if curpos==0 then cmdstr=cmdstr..char
      else cmdstr=cmdstr:sub(1,-1-curpos)..char..cmdstr:sub(-curpos)
      end
    end
    ShowCmd()
  elseif eventname =='touch' then
    SetColor(PanelCl)
    eventTouch(char, code, mTouch)
    ShowCmd()
  elseif eventname =='scroll' then
    SetColor(PanelCl)
    eventScroll(dir)
    ShowCmd()
  end
end
loadScreen()
print('\n'..locale.ThankYou)
