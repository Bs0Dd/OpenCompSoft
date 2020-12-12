--[[ RemoteDISK NetServer v1.03.
Server program for make NetClient Network disks. Client connecting by port, hostname, login and password
Uses settings from "/etc/rc.cfg"
Author: Bs()Dd
]]
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local event = require("event")
local seriz = require("serialization")

function request(_, _, opp, _, _, call, one, two, thr, four)
    event.ignore("modem_message", request)
    logfil, why = fs.open("/etc/rdwork.log", "a")

    if call == "RDCL" then
        if args.log then
            logfil:write("[" .. os.date("%T") .. "] " .. "[CONNECT]: " .. opp .. " is connected\n")
        end
        if one == args.hostname then
            card.send(opp, port, "RDAN")
            _, _, opp, _, _, call, one, two = event.pull("modem_message")
            if call == "RDLG" and one == args.login and two == args.password then
                if online.n == maxonline then
                    card.send(opp, port, "RDAU", "RDFULL")
                    if args.log then
                        logfil:write(
                            "[" .. os.date("%T") .. "] " .. "[LOGIN]: " .. opp .. " tried to login to full server\n"
                        )
                    end
                    return
                end
                card.send(opp, port, "RDAU", "OK", rfs.address)
                if online[opp] == nil then
                    online[opp] = true
                    online.n = online.n + 1
                    ofdesc[opp] = {n = 0}
                end
                if args.log then
                    logfil:write("[" .. os.date("%T") .. "] " .. "[LOGIN]: " .. opp .. " is logged in\n")
                end
            elseif call == "RDLG" then
                card.send(opp, port, "RDAU", "FAIL")
                if args.log then
                    logfil:write("[" .. os.date("%T") .. "] " .. "[LOGIN]: " .. opp .. " is failed to log in\n")
                end
            end
        end
        logfil:close()
        event.listen("modem_message", request)
        return
    end

    if online[opp] == nil then
        card.send(opp, port, "RDNAUT")
        if args.log then
            logfil:write(
                "[" .. os.date("%T") .. "] " .. "[LOGIN]: " .. opp .. " tried to get access without authorization\n"
            )
        end
        logfil:close()
        event.listen("modem_message", request)
        return
    end

    if call == "RDISDIR" then
        card.send(opp, port, "RDISDIRA", rfs.isDirectory(one))
        if args.log == 2 then
            logfil:write(
                "[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called isDirectory("' .. one .. '")\n'
            )
        end
    elseif call == "RDLMOD" then
        card.send(opp, port, "RDLMODA", rfs.lastModified(one))
        if args.log == 2 then
            logfil:write(
                "[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called lastModified("' .. one .. '")\n'
            )
        end
    elseif call == "RDLIST" then
        lst, err = rfs.list(one)
        if err ~= nil then
            card.send(opp, port, "RDLISTA", nil, err)
        end
        if lst ~= nil then
            card.send(opp, port, "RDLISTA", seriz.serialize(lst))
        else
            card.send(opp, port, "RDLISTA", nil, nil)
        end
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called list("' .. one .. '")\n')
        end
    elseif call == "RDTOTL" then
        card.send(opp, port, "RDTOTLA", rfs.spaceTotal())
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. " called spaceTotal()\n")
        end
    elseif call == "RDOPEN" then
        if ofdesc[opp].n == maxdescr then
            card.send(opp, port, "RDOPENA", nil, "too many open handles")
            logfil:close()
            event.listen("modem_message", request)
            return
        else
            fdes, err = rfs.open(one, two)
            if err ~= nil then
                card.send(opp, port, "RDOPENA", nil, err)
            else
                ofdesc[opp][tonumber(tostring(fdes))] = fdes
                ofdesc[opp].n = ofdesc[opp].n + 1
                card.send(opp, port, "RDOPENA", tonumber(tostring(fdes)))
            end
            if args.log == 2 then
                logfil:write(
                    "[" ..
                        os.date("%T") ..
                            "] " .. "[VERBOSE]: " .. opp .. ' called open("' .. one .. '", "' .. two .. '")\n'
                )
            end
        end
    elseif call == "RDRM" then
        card.send(opp, port, "RDRMA", rfs.remove(one))
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called remove("' .. one .. '")\n')
        end
    elseif call == "RDRN" then
        card.send(opp, port, "RDRNA", rfs.rename(one, two))
        if args.log == 2 then
            logfil:write(
                "[" ..
                    os.date("%T") ..
                        "] " .. "[VERBOSE]: " .. opp .. ' called rename("' .. one .. '", "' .. two .. '")\n'
            )
        end
    elseif call == "RDREAD" then
        if ofdesc[opp][one] ~= nil then
            sended = 0
            remain = two
            if two > maxpackspace then
                bread = maxpackspace
            else
                bread = two
            end
            while sended < two do
                rdd = rfs.read(ofdesc[opp][one], bread)
                card.send(opp, port, "RDREADA", rdd)
                sended = sended + maxpackspace
                remain = remain - maxpackspace
                if remain < maxpackspace then
                    bread = remain
                end
            end
        else
            card.send(opp, port, "RDREADA", nil, "bad file descriptor")
        end
        if args.log == 2 then
            logfil:write(
                "[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. " called read(" .. one .. ', "' .. two .. '")\n'
            )
        end
    elseif call == "RDCLS" then
        if ofdesc[opp][one] == "closed" then
            card.send(opp, port, "RDCLSA")
        elseif ofdesc[opp][one] ~= nil then
            card.send(opp, port, "RDCLSA", rfs.close(ofdesc[opp][one]))
            ofdesc[opp][one] = "closed"
            ofdesc[opp].n = ofdesc[opp].n - 1
        else
            card.send(opp, port, "RDCLSA", nil, "bad file descriptor")
        end
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. " called close(" .. one .. ")\n")
        end
    elseif call == "RDGLAB" then
        card.send(opp, port, "RDGLABA", rfs.getLabel())
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. " called getLabel()\n")
        end
    elseif call == "RDSEEK" then
        card.send(opp, port, "RDSEEKA", rfs.seek(one, two, thr))
        if args.log == 2 then
            logfil:write(
                "[" ..
                    os.date("%T") ..
                        "] " .. "[VERBOSE]: " .. opp .. " called seek(" .. one .. ', "' .. two .. '", ' .. thr .. ")\n"
            )
        end
    elseif call == "RDFSIZ" then
        card.send(opp, port, "RDFSIZA", rfs.size(one))
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called size("' .. one .. '")\n')
        end
    elseif call == "RDISRO" then
        card.send(opp, port, "RDISROA", rfs.isReadOnly())
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. " called isReadOnly()\n")
        end
    elseif call == "RDSLAB" then
        card.send(opp, port, "RDSLABA", rfs.setLabel(one))
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called setLabel("' .. one .. '")\n')
        end
    elseif call == "RDMKDR" then
        card.send(opp, port, "RDMKDRA", rfs.makeDirectory(one))
        if args.log == 2 then
            logfil:write(
                "[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called makeDirectory("' .. one .. '")\n'
            )
        end
    elseif call == "RDISEX" then
        card.send(opp, port, "RDISEXA", rfs.exists(one))
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. ' called exists("' .. one .. '")\n')
        end
    elseif call == "RDFREE" then
        card.send(opp, port, "RDFREEA", rfs.spaceUsed())
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[VERBOSE]: " .. opp .. " called spaceUsed()\n")
        end
    elseif call == "RDWRT" then
        oneb = one
        if ofdesc[opp][one] ~= nil then
            fhand = ofdesc[opp][one]
            card.send(opp, port, "RDWRTA")
            readed = 0
            rdata = ""
            while readed < two do
                while true do
                    _, _, ropp, _, _, call, one = event.pull("modem_message")
                    if ropp == opp then
                        break
                    end
                end
                if one ~= nil then
                    rdata = rdata .. one
                end
                readed = readed + #one
            end
            stat, err = rfs.write(fhand, rdata)
            card.send(opp, port, "RDWRTPA", stat, err)
        else
            card.send(opp, port, "RDWRTA", nil, "bad file descriptor")
        end
        if args.log == 2 then
            logfil:write(
                "[" ..
                    os.date("%T") ..
                        "] " .. "[VERBOSE]: " .. opp .. " called write(" .. oneb .. ", data len: " .. #rdata .. ")\n"
            )
        end
    elseif call == "RDBYE" then
        online[opp] = nil
        online.n = online.n - 1
        for _, dcl in pairs(ofdesc[opp]) do
            if dcl ~= "closed" then
                rfs.close(dcl)
            end
        end
        ofdesc[opp] = nil
        card.send(opp, port, "RDBYEA", "user logged off")
        if args.log == 2 then
            logfil:write("[" .. os.date("%T") .. "] " .. "[CONNECT]: " .. opp .. " disconnected\n")
        end
    end
    logfil:close()
    event.listen("modem_message", request)
end

function start()
    if work == nil then
        if component.list("modem")() == nil then
            io.stderr:write("No Network Card is detected.")
            return
        end
        card = component.proxy(component.list("modem")())
        work = true
        print("RemoteDISK NetServer v1.03\n")

        if args == nil then
            io.stderr:write("FATAL ERROR! No settings found!")
            return
        end
        port = args.port
        card.open(port)
        maxpackspace = card.maxPacketSize() - 20
        rfs = component.proxy(args.hddaddress)
        if rfs == nil then
            io.stderr:write("FATAL ERROR! Hard drive insn't exists!")
            return
        else
            print("Hard drive " .. rfs.address .. " is selected")
            print('Server "' .. args.hostname .. '", port ' .. port)
        end
        if args.mode == 1 then
            maxonline = 14
            maxdescr = 1
        elseif args.mode == 2 then
            maxonline = 7
            maxdescr = 2
        else
            print("FATAL ERROR! Incorrect mode.")
            return
        end
        if args.log then
            logfil, why = io.open("/etc/rdwork.log", "w")
            if logfil == nil then
                print("FATAL ERROR! Can't open logging file: " .. why)
                return
            end
            print("Logging started!")
            logfil:write("[" .. os.date("%T") .. "] " .. "[STATUS]: Server started\n")
            logfil:close()
        end
        online = {n = 0}
        ofdesc = {}
        work = true
        event.listen("modem_message", request)
    else
        io.stderr:write("Server already started!\n")
    end
end

function stop()
    if work == true then
        work = nil
        event.ignore("modem_message", request)
        card.close(port)
        if args.log then
            logfil = io.open("/etc/rdwork.log", "a")
            logfil:write("[" .. os.date("%T") .. "] " .. "[STATUS]: Server stopped\n")
            logfil:close()
        end
        print("Server stopped.")
    else
        io.stderr:write("Server isn't working now!\n")
    end
end

