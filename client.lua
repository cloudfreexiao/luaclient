#!/usr/bin/env lua53
assert(_VERSION == "Lua 5.3")

package.path  = "lualib/?.lua;lualib/socket/?.lua;" .. package.path
package.cpath = "luaclib/?.so;"

local simpleui = require "simpleui"
inspect = require "inspect"

local websocket_async = require "websocket.client_async"

local ws_client = {}

local function connect(self, protocol)
    self.ws = websocket_async()

    self.ws:on_message(function(message)
        print("Receiving: '" .. tostring(message) .. "'")
    end)
    self.ws:on_connected(function(ok, err)
        if err then
            print("on_connected error", err)
            self.ws:close()
            self.ws = nil
        else
            print("connect succ")
            self.is_connected = true
        end
    end)

    self.ws:on_disconnected(function()
        print("Disconnected")
        self.ws = nil
        self.is_connected = false
    end)
    
    local url = nil
    local sslparams =  nil
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
    self.ws:connect(url, nil, sslparams)
end


connect(ws_client, "ws")

while true do
    if ws_client.ws then
        ws_client.ws.step()
        if ws_client.is_connected then
            ws_client.ws:send("hello world")
        end
    end
end