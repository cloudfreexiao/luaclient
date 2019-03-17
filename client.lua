#!/usr/bin/env lua53
assert(_VERSION == "Lua 5.3")

package.path  = "lualib/?.lua;lualib/socket/?.lua;lualib/termfx/?.lua;" .. package.path
package.cpath = "luaclib/?.so;"

inspect = require "inspect"

local tfx = require "termfx"
local ui = require "simpleui"

local ws_client = require "ws_client"
local http_client = require "http_client"

ok, err = pcall(function()
    tfx.init()
    tfx.inputmode(tfx.input.ALT + tfx.input.MOUSE)
    tfx.outputmode(tfx.output.COL256)
    
    ws_client.connect()
end)

local function do_tfx_evt(evt)
    if evt.char == "q" or evt.char == "Q" then
        return ui.ask("Really quit?")
    elseif evt.char == 'h' or evt.char == "H" then
        http_client.request_uri()
    else
        ws_client.send("hello world")
    end

    if evt.key == tfx.key.CTRL_C then
        return true
    end

    return false
end

ok, err = pcall(function()
    local quit = false
    local evt = {}

    repeat
        tfx.clear(tfx.color.WHITE, tfx.color.BLACK)
        tfx.printat(1, tfx.height(), "press Q to quit")
        
        tfx.present()
        evt = tfx.pollevent()
        ws_client.update()
        
        tfx.attributes(tfx.color.WHITE, tfx.color.BLUE)

        quit = do_tfx_evt(evt)
    until quit
end)
ws_client.shutdown()
tfx.shutdown()
if not ok then print("Error: "..err) end
