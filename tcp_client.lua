local socket  = require "socket"


local tcp_client = {}

local function pack_msg(str)
    if _VERSION ~= "Lua 5.3" then            
        local len = string.len(str)
        local leninfo = string.pack("bb", math.floor(len/256), len%256)
        return string.pack("A", leninfo .. str)
    else
        return string.pack(">s2", str)
    end
end

-- return package and now buffer
-- local function unpack_package(buffer)
--     local size = #buffer
--     if size < 2 then
--         return nil, buffer
--     end

--     local s = string.byte(buffer, 1) * 256 + string.byte(buffer, 2)
--     if size < s + 2 then
--         return nil, buffer
--     end
--     return string.sub(buffer, 3, 2+s), string.sub(buffer, 3 + s)
-- end

local function recv_pack(sock)
    local len = sock:receive(2)
    if len then
        len = len:byte(1) * 256 + len:byte(2)
        local msg, err, parts = sock:receive(len)
        if msg and #msg == len then
            return msg
        else
            return nil, err
        end
    end
end


local function connect(ip, port)
    tcp_client.sock = socket.connect(ip, port)
end

local function shutdown()
    tcp_client.sock:close()
    tcp_client.sock = nil
end

local function update()
    if tcp_client.sock then
        local msg = recv_pack(tcp_client.sock)
        if msg then
            print("recive msg:" .. inspect(msg) )
        else
            print("socket error:" .. err)
            shutdown()
        end
    end
end

local function send(data)
    if tcp_client.sock then
        local msg = pack_msg(data)
        tcp_client.sock:send(msg)
    end
end

return {
    connect = connect,
    update = update,
    send = send,
    shutdown = shutdown,
}
