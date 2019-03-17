
local websocket_async = require "websocket.client_async"

local ws_client = {}

local function connect(protocol)
    ws_client.ws = websocket_async()

    ws_client.ws:on_message(function(message)
        print("Receiving: '" .. tostring(message) .. "'")
    end)
    ws_client.ws:on_connected(function(ok, err)
        if err then
            print("on_connected error", err)
            ws_client.ws:close()
            ws_client.ws = nil
        else
            print("connect succ")
            ws_client.is_connected = true
        end
    end)

    ws_client.ws:on_disconnected(function()
        print("Disconnected")
        ws_client.ws = nil
        ws_client.is_connected = false
    end)
    
    local url = nil
    local sslparams =  nil
    protocol = protocol or "ws"
    if protocol == "ws" then
        url = "ws://echo.websocket.org"
    else
        sslparams = {
            mode = "client",
            protocol = "tlsv1_2",
            verify = "none",
            options = "all",
        }
        url = "wss://echo.websocket.org"
    end
    
    print("Connecting to " .. url)
    ws_client.ws:connect(url, nil, sslparams)
end

local function send(msg)
    --TODO: 序列化
    if ws_client.is_connected then
        ws_client.ws:send(msg)
    else
        print("is connecting please wait--- ")
    end
end

local function update()
    if ws_client.ws then
        ws_client.ws.step()
    end
end

local function shutdown()
    if ws_client.ws and ws_client.is_connected then
        ws_client.ws = nil
        ws_client.is_connected = false
    end
end

return {
    connect = connect,
    update = update,
    send = send,
    shutdown = shutdown,
}