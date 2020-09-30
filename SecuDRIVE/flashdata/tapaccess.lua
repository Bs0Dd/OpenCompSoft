drive = component.proxy(component.list("tape_drive")())
red = component.proxy(component.list("redstone")())

--{PASSWORD CODE. REMIND AND WRITE TO TAPE}--
code = 'MARAPARA'
--{INCORRECT CODE SIGNAL SIDE}--
incorr=2 
--{CORRECT CODE SIGNAL SIDE}--
corr=5
--{END CONF.}--

local function lamp(colcode)
  llist = component.list("colorful_lamp")()
  if llist ~= nil then
    ldev = component.proxy(llist)
    if colcode == 0 then ldev.setLampColor(25368) end
    if colcode == 1 then ldev.setLampColor(512) end
    if colcode == 2 then ldev.setLampColor(16384) end
  end
end

while true do
 if drive.isReady() then
  drive.seek(-drive.getSize())
  tcode = drive.read(#code)
  while drive.isReady() == true do
  if code == tcode then
   red.setOutput(corr, 15)
   red.setOutput(incorr, 0)
   lamp(1)
  else
   red.setOutput(incorr, 15)
   red.setOutput(corr, 0)
   lamp(2)
  end
  end
 else
  red.setOutput(corr, 0)
  red.setOutput(incorr, 0)
  lamp(0)
 end
end
