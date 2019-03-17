local http = require "http"
local ltn12 = require "ltn12"

local request_body = [[login=user&password=123]]
local response_body = {}


local function request_uri(url, method)
    local res, code, response_headers = http.request{
        url = url or "http://httpbin.org/post",
        method = method or "POST",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded";
            ["Content-Length"] = #request_body;
            },
            source = ltn12.source.string(request_body),
            sink = ltn12.sink.table(response_body),
    }
    
    print("response:", inspect(res))
    print("code", code)
    print("response_headers", inspect(response_headers))
end

return {
    request_uri = request_uri, 
}


