--[[ RemoteDISK NetClient Driver library v1.03.
Driver for NetClient Network disks.
Makes table with filesystem functions to use with filesystem.mount, for example
Using address: <real remote filesystem address>-rfs
Author: Bs()Dd
]]
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local io = require("io")
local event = require("event")
local seriz = require("serialization")

local remdfs = {}

function remdfs.connect(port, hostname, login, passw)
    local function gmesg(code)
        while true do
            _, _, opp, _, _, call, data, addata = event.pull(5, "modem_message")
            if call == code then
                break
            end
            if opp == nil then
                return nil, nil, "No answer from opponent"
            end
            if call == "RDNAUT" then
                return opp, nil, "You aren't logged in"
            end
        end
        return opp, data, addata
    end

    checkArg(1, port, "number")
    checkArg(2, hostname, "string")
    checkArg(3, login, "string")
    checkArg(4, passw, "string")
    if component.list("modem")() == nil then
        return nil, "No Network Card is detected"
    end
    local card = component.proxy(component.list("modem")())
    card.open(port)
    card.broadcast(port, "RDCL", hostname)
    local opp, _, err = gmesg("RDAN")
    if err ~= nil then
        return nil, err
    end
    card.send(opp, port, "RDLG", login, passw)
    local _, data, dadr = gmesg("RDAU")
    if data == "FAIL" then
        return nil, "Authorization failed"
    elseif data == "RDFULL" then
        return nil, "Server is full"
    elseif data == nil then
        return nil, "Unknown authorization answer"
    elseif data == "OK" then
        local proxyObj = {}
        proxyObj.maxpackspace = card.maxPacketSize() - 20
        proxyObj.port = port
        proxyObj.opponent = opp
        proxyObj.type = "filesystem"
        proxyObj.address = dadr:gsub("-", "") .. "-rfs"
        local opponent = opp

        proxyObj.isDirectory = function(path)
            checkArg(1, path, "string")
            path = fs.canonical(path)
            card.send(opponent, port, "RDISDIR", path)
            _, stat, err = gmesg("RDISDIRA")
            return stat, err
        end
        proxyObj.lastModified = function(path)
            checkArg(1, path, "string")
            path = fs.canonical(path)
            card.send(opponent, port, "RDLMOD", path)
            _, modif, err = gmesg("RDLMODA")
            return modif, err
        end
        proxyObj.list = function(path)
            checkArg(1, path, "string")
            path = fs.canonical(path)
            card.send(opponent, port, "RDLIST", path)
            _, lstr, err = gmesg("RDLISTA")
            if err ~= nil and lstr == nil then
                return nil, err
            end
            if lstr ~= nil then
                list = seriz.unserialize(lstr)
            end
            return list
        end
        proxyObj.spaceTotal = function()
            card.send(opponent, port, "RDTOTL")
            _, space, err = gmesg("RDTOTLA")
            return space, err
        end
        proxyObj.open = function(path, mode)
            checkArg(1, path, "string")
            checkArg(2, mode, "string")
            path = fs.canonical(path)
            if mode ~= "r" and mode ~= "rb" and mode ~= "w" and mode ~= "wb" and mode ~= "a" and mode ~= "ab" then
                error("unsupported mode", 2)
            end
            card.send(opponent, port, "RDOPEN", path, mode)
            _, desc, err = gmesg("RDOPENA")
            return desc, err
        end
        proxyObj.remove = function(path)
            checkArg(1, path, "string")
            path = fs.canonical(path)
            card.send(opponent, port, "RDRM", path)
            _, stat, err = gmesg("RDRMA")
            return stat, err
        end
        proxyObj.rename = function(path, newpath)
            checkArg(1, path, "string")
            checkArg(1, newpath, "string")
            path = fs.canonical(path)
            newpath = fs.canonical(newpath)
            card.send(opponent, port, "RDRN", path, newpath)
            _, desc, err = gmesg("RDRNA")
            return stat, err
        end
        proxyObj.read = function(fd, count)
            checkArg(1, fd, "number")
            checkArg(2, count, "number")
            card.send(opponent, port, "RDREAD", fd, count)
            readed = 0
            rdata = ""
            while readed < count do
                while true do
                    ropp, reciv, err = gmesg("RDREADA")
                    if ropp == opp then
                        break
                    end
                end
                if err ~= nil then
                    return nil, err
                end
                if reciv ~= nil then
                    rdata = rdata .. reciv
                else
                    if rdata == "" then
                        rdata = nil
                    end
                    break
                end
                readed = readed + proxyObj.maxpackspace
            end
            return rdata
        end
        proxyObj.close = function(fd)
            checkArg(1, fd, "number")
            card.send(opponent, port, "RDCLS", fd)
            _, stat, err = gmesg("RDCLSA")
            return stat, err
        end
        proxyObj.getLabel = function()
            card.send(opponent, port, "RDGLAB")
            _, label, err = gmesg("RDGLABA")
            return label, err
        end
        proxyObj.seek = function(fd, kind, offset)
            checkArg(1, fd, "number")
            checkArg(2, kind, "string")
            checkArg(3, offset, "number")
            if kind ~= "set" and kind ~= "cur" and kind ~= "end" then
                error("invalid mode", 2)
            end
            card.send(opponent, port, "RDSEEK", fd, kind, offset)
            _, cseek, err = gmesg("RDSEEKA")
            return cseek, err
        end
        proxyObj.size = function(path)
            checkArg(1, path, "string")
            path = fs.canonical(path)
            card.send(opponent, port, "RDFSIZ", path)
            _, fsize, err = gmesg("RDFSIZA")
            return fsize, err
        end
        proxyObj.isReadOnly = function()
            card.send(opponent, port, "RDISRO")
            _, isro, err = gmesg("RDISROA")
            return isro, err
        end
        proxyObj.setLabel = function(newlabel)
            checkArg(1, newlabel, "string")
            card.send(opponent, port, "RDSLAB", newlabel)
            _, lab, err = gmesg("RDSLABA")
            return lab, err
        end
        proxyObj.makeDirectory = function(path)
            checkArg(1, path, "string")
            path = fs.canonical(path)
            card.send(opponent, port, "RDMKDR", path)
            _, stat, err = gmesg("RDMKDRA")
            return stat, err
        end
        proxyObj.exists = function(path)
            checkArg(1, path, "string")
            path = fs.canonical(path)
            card.send(opponent, port, "RDISEX", path)
            _, stat, err = gmesg("RDISEXA")
            return stat, err
        end
        proxyObj.spaceUsed = function()
            card.send(opponent, port, "RDFREE")
            _, stat, err = gmesg("RDFREEA")
            return stat, err
        end
        proxyObj.write = function(fd, data)
            checkArg(1, fd, "number")
            checkArg(2, data, "string")
            card.send(opponent, port, "RDWRT", fd, #data)
            _, stat, err = gmesg("RDWRTA")
            if err ~= nil then
                return nil, err
            end
            sent = 0
            while sent < #data do
                scut = data:sub(sent + 1, sent + proxyObj.maxpackspace)
                card.send(opponent, port, "RDWRTR", scut)
                sent = sent + proxyObj.maxpackspace
            end
            _, stat, err = gmesg("RDWRTPA")
            if err ~= nil then
                return nil, err
            end
            return stat
        end

        proxyObj.disconnect = function()
            card.send(opponent, port, "RDBYE")
            _, stat, err = gmesg("RDBYEA")
            return stat, err
        end

        return proxyObj
    end
end

return remdfs

