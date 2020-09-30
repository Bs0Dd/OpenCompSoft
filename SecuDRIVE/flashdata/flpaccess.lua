red = component.proxy(component.list("redstone")())
drive = component.proxy(component.list("disk_drive")())

--{PASSWORD CODE. REMIND AND WRITE TO TAPE}--
code = 'MAMM'
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
 if not drive.isEmpty() then
    floppy = component.proxy(drive.media())
    if floppy.readByte ~= nil then 
      local curs = 0
      local discode = ''
      while curs ~= #code do
        discode = discode .. string.char(floppy.readByte(curs+1))
        curs = curs + 1
      end
      while not drive.isEmpty() do
       if code == discode then
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
      while not drive.isEmpty() do
       red.setOutput(incorr, 15)
       red.setOutput(corr, 0)
       lamp(2)
      end
    end
 else
  while drive.isEmpty() do
   red.setOutput(corr, 0)
   red.setOutput(incorr, 0)
   lamp(0)
  end
 end
end
