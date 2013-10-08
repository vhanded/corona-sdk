--
-- Chartboost Corona SDK
-- Created by: Chris
--

-- CBURLOpenerDelegate methods:
--      urlOpenAttempted(boolean opened, string url)

local class = require "chartboost.libraries.lib.class"
local CBUtility = require "chartboost.libraries.CBUtility"
local system = require("system")

local CBURLOpener = class(function(self, delegate)
    assert(type(delegate) == "table", "First parameter 'delegate' must be a table of functions.")
    self.delegate = delegate
end)

local function doOpenUrl(delegate, url)
    assert(type(url) == "string", "First parameter 'url' must be a string.")

    local success = system.openURL(url)

    -- TODO is there anything iOS specific?
    if not success then
        if CBUtility.getUrlScheme(url) == "market" then
            url = "http://market.android.com/" .. string.sub(url, 10)
            success = system.openURL(url)
        end
    end

    delegate:urlOpenAttempted(success, url)
end

function CBURLOpener:open(url)
    assert(type(url) == "string", "First parameter 'url' must be a string.")
    if not url then
        return
    end

    local scheme = CBUtility.getUrlScheme(url)
    if scheme == nil then
        self.delegate:urlOpenAttempted(false, url)
        return
    end

    -- TODO follow link silently for http/https to look for a forward
    doOpenUrl(self.delegate, url)
end

return CBURLOpener