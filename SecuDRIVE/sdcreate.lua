--[[ SecuDrive Creator.
Program for creating EEPROM-Floppy or EEPROM-Computronics tape pair for using in key-based access computer system
Author: Bs()Dd

Requirements to computer system:
 - Tier 1 Computer
 - Tier 1 Processor
 - 1x Tier 1 Memory
 - Tier 1 Redstone Card or Redstone I/O block
 - Floppy drive or Computronics streamer
 - Computronics Colorful lamp (access indicator, optionally)
]]

component = require('component')

local function confirm(msg)
    print(msg)
    print("Type `y` to write, `s` to skip (if medium already written).")
    repeat
      local response = io.read()
      if response and response:lower():sub(1, 1) == "s" then
        return false
      end
    until response and response:lower():sub(1, 1) == "y"
  return true
end

print('SecuDrive Creator v1.1')
print('2020 (c) Compys Security Software\n')
print('What type of key will be use (floppy, tape): ')
repeat
       response = io.read()
    until response == "floppy" or response == "tape"
print('Enter number side for correct code signal (0-5): ')
repeat
       corr = tonumber(io.read())
    until corr < 6 and corr > -1
print('Enter number side for incorrect code signal (0-5): ')
repeat
       inco = tonumber(io.read())
    until inco < 6 and inco > -1
print('Enter password code: ')    
 local passw = io.read()  
if response == "tape" then
   if confirm("\nInsert EEPROM in computer\nOLD DATA WILL BE ERASED!") then
     local chip = component.eeprom
     chip.set(string.format('local function lamp(colcode)\nllist = component.list("colorful_lamp")()\nif llist ~= nil then\nldev = component.proxy(llist)\nif colcode == 0 then ldev.setLampColor(25368) end\nif colcode == 1 then ldev.setLampColor(512) end\nif colcode == 2 then ldev.setLampColor(16384) end\nend\nend\ndrive = component.proxy(component.list("tape_drive")())\nred = component.proxy(component.list("redstone")())\ncode = "%s"\nincorr= %s\ncorr= %s\nwhile true do\nif drive.isReady() then\ndrive.seek(-drive.getSize())\ntcode = drive.read(#code)\nwhile drive.isReady() == true do\nif code == tcode then\nred.setOutput(corr, 15)\nred.setOutput(incorr, 0)\nlamp(1)\nelse\nred.setOutput(incorr, 15)\nred.setOutput(corr, 0)\nlamp(2)\nend\nend\nelse\nred.setOutput(corr, 0)\nred.setOutput(incorr, 0)\nlamp(0)\nend\nend', passw, inco, corr))
     chip.setLabel('SecuDrive Tape BIOS')
     print('OK!\n')
   end
   if confirm("Insert tape in streamer\nOLD DATA WILL BE ERASED!") then
     local tape = component.tape_drive
     tape.stop()
     tape.seek(-tape.getSize())
     tape.stop()
     tape.write(passw)
     tape.stop()
     tape.seek(-tape.getSize())
     tape.stop()
     print('OK!\n')
     print("Enter new label for tape. Leave input blank to leave the label unchanged.")
     label = io.read()
     if label and #label > 0 then
       tape.setLabel(label)
       print('')
     end
   end
   print('SecuDrive components successfully created!')
end
if response == "floppy" then
  if confirm("\nInsert EEPROM in computer\nOLD DATA WILL BE ERASED!") then
     local chip = component.eeprom
     chip.set(string.format('red = component.proxy(component.list("redstone")())\ndrive = component.proxy(component.list("disk_drive")())\ncode = "%s"\nincorr= %s \ncorr= %s\nlocal function lamp(colcode)\nllist = component.list("colorful_lamp")()\nif llist ~= nil then\nldev = component.proxy(llist)\nif colcode == 0 then ldev.setLampColor(25368) end\nif colcode == 1 then ldev.setLampColor(512) end\nif colcode == 2 then ldev.setLampColor(16384) end\nend\nend\nwhile true do\nif not drive.isEmpty() then\nfloppy = component.proxy(drive.media())\nif floppy.readByte ~= nil then\nlocal curs = 0\nlocal discode = ""\nwhile curs ~= #code do\ndiscode = discode .. string.char(floppy.readByte(curs+1))\ncurs = curs + 1\nend\nwhile not drive.isEmpty() do\nif code == discode then\nred.setOutput(corr, 15)\nred.setOutput(incorr, 0)\nlamp(1)\nelse\nred.setOutput(incorr, 15)\nred.setOutput(corr, 0)\nlamp(2)\nend\nend\nelse\nwhile not drive.isEmpty() do\nred.setOutput(incorr, 15)\nred.setOutput(corr, 0)\nlamp(2)\nend\nend\nelse\nwhile drive.isEmpty() do\nred.setOutput(corr, 0)\nred.setOutput(incorr, 0)\nlamp(0)\nend\nend\nend', passw, inco, corr))
     chip.setLabel('SecuDrive Floppy BIOS')
     print('OK!\n')
   end
   if confirm("Turn floppy to UNMANAGED MODE and insert in drive\nOLD DATA WILL BE ERASED!") then
     local floppy = component.proxy(component.disk_drive.media())
     local curs = 0
     while curs ~= #passw do
        floppy.writeByte(curs+1, string.byte(passw:sub(curs+1,curs+1)))	
        curs = curs + 1
     end
     print('OK!\n')
     print("Enter new label for floppy. Leave input blank to leave the label unchanged.")
     label = io.read()
     if label and #label > 0 then
       floppy.setLabel(label)
       print('')
     end
   end
   print('SecuDrive components successfully created!')
end
