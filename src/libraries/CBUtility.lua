--
-- Chartboost Corona SDK
-- Created by: Chris
--

local surl = require("socket.url")

local function split(inputstr, sep)
    sep = sep or "%s"
    assert(type(inputstr) == "string", "First parameter 'inputstr' must be a string.")
    assert(type(sep) == "string", "Second parameter 'sep' must be a string.")
    local t = {}
    local i = 1
    for str in inputstr:gmatch("([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

local function queryStringToTable(url)
    assert(type(url) == "string", "First parameter 'url' must be a string.")
    if url:sub(1, 1) == "?" then
        url = url:sub(2)
    end

    local t = {}
    local params = split(url, "&")
    for i,v in ipairs(params) do
        local parts = split(v, "=")
        if parts[1] and parts[2] then
            t[parts[1]] = surl.unescape(parts[2])
        end
    end

    return t
end

local function getUrlScheme(url)
    assert(type(url) == "string", "First parameter 'url' must be a string.")
    local parsed_url = surl.parse(url)
    return parsed_url.scheme
end

-- this is a scaling method
-- we don't return anything other than 1 right now, but we could dependent on device parameters
local function dpToPixels(dp)
    assert(type(dp) == "number", "First parameter 'dp' must be a number.")
    local density = 1 -- TODO density!!!
    return density * dp
end

local util = {
    dpToPixels = dpToPixels,
    getUrlScheme = getUrlScheme,
    split = split,
    queryStringToTable = queryStringToTable
}

return util