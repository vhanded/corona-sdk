--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create and manage a webview-based impression.
-- Instantiate using CBWebViewProtocol(CBImpression)
--   Call method 'protocol:prepareWithResponse(table)' begin the process of creating
--     the impression, passing in the json data from the server
--   Call method 'protocol:destroy()' to remove the view from the stage and perform cleanup
--
-- Internally, the class CBWebView is used to create the actual webview view.
-- Instantiate using CBWebView(CBWebViewProtocol)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:layoutSubviews(width, height)' to initialize the view's content
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local socketurl = require "socket.url"
local class = require "chartboost.libraries.lib.class"
local CBViewProtocol, CBViewBase = unpack(require "chartboost.CBViewProtocol")
local CBUtility = require "chartboost.libraries.CBUtility"

local HTML_FILENAME = "tempWebView.html"

local CBWebView = class(function(self, nativeViewProtocol)
    assert(type(nativeViewProtocol) == "table", "First parameter 'viewProtocol' must be a CBWebViewProtocol.")
    self.viewProtocol = nativeViewProtocol
    self.viewBase = CBViewBase(self)

    self.group = display.newGroup()
end)

--- params: self, CBImpression
local CBWebViewProtocol = class(function(self, impression)
    assert(type(impression) == "table", "First parameter 'impression' must be a CBImpression.")
    self.viewProtocol = CBViewProtocol(impression, function()
        self.view = CBWebView(self)
        return self.view
    end, 0)
end)

function CBWebViewProtocol:prepareWithResponse(response)
    assert(type(response) == "table", "First parameter 'response' must be a table.")
    self.viewProtocol:prepareWithResponse(response)

    self.html = response["html"]
    if not html then return end -- html invalid for some reason

    local htmlFile = system.pathForFile(HTML_FILENAME , system.TemporaryDirectory)
    local file = io.open(htmlFile, "w")
    file:write(self.html)
    io.close(file)
    file = nil

    -- since we don't load any assets, we have to manually create the chartboost view
    self.viewProtocol:setReadyToDisplay()
end

-- create the actual chartboost view object
-- createViewObject() is a var passed in

-- make the chartboost view and its data ready for GC.
-- self calls through to #destroyView()
function CBWebViewProtocol:destroy()
    self.viewProtocol:destroy()
end

-- make the chartboost view (not its data) ready for GC.
function CBWebViewProtocol:destroyView()
    --
end


function CBWebView:layoutSubviews(w, h)
    assert(type(w) == "number", "First parameter 'w' must be a number.")
    assert(type(h) == "number", "Second parameter 'h' must be a number.")
    local cbProxy = self.viewProtocol.viewProtocol.impression.cbProxy
    local orientation = cbProxy.getOrientation()

    local function webListener(event)
        local url = event.url

        local protocol = CBUtility.getUrlScheme(url)
        if not protocol then
            if self.viewProtocol.viewProtocol.closeCallback then
                self.viewProtocol.viewProtocol.closeCallback()
            end
            return false
        end

        if protocol == "chartboost" then
            local items = CBUtility.split(url, "/")
            local urlCount = #items
            if (urlCount < 3) then
                if self.viewProtocol.viewProtocol.closeCallback then
                    self.viewProtocol.viewProtocol.closeCallback()
                end
                return false
            end

            local fn = items[3]

            if fn == "close" then
                if self.viewProtocol.viewProtocol.closeCallback then
                    self.viewProtocol.viewProtocol.closeCallback()
                end
            elseif fn == "link" then
                if self.viewProtocol.viewProtocol.closeCallback then
                    self.viewProtocol.viewProtocol.closeCallback()
                end
            elseif fn == "link" then
                if (urlCount < 4) then
                    if self.viewProtocol.viewProtocol.closeCallback then
                        self.viewProtocol.viewProtocol.closeCallback()
                    end
                    return false
                end

                local moreData, decodedUrl

                decodedUrl = socketurl.unescape(items[4])
                if (urlCount > 4) then
                    moreData = CBUtility.queryStringToTable(items[4])
                end

                if self.viewProtocol.viewProtocol.clickCallback then
                    self.viewProtocol.viewProtocol.clickCallback(decodedUrl, moreData)
                end

                return true
            end
        end

        if event.errorCode then
            if self.viewProtocol.viewProtocol.failCallback then
                self.viewProtocol.viewProtocol.failCallback("unable to load webpage from chartboost response, url: " .. url)
            end
        else
            if self.viewProtocol.viewProtocol.displayCallback then
                self.viewProtocol.viewProtocol.displayCallback()
            end
        end
    end

    local webView = native.newWebView(0, 0, display.contentWidth, display.contentHeight, webListener)
    webView:request(HTML_FILENAME , system.TemporaryDirectory)
    -- TODO: how to make system.ResourceDirectory the base directory??
    webView:addEventListener("urlRequest", webListener)
    self.webView = webView
end

function CBWebView:destroy()
    self.viewBase:destroy()
    if (self.webView) then
        self.webView:removeSelf()
        self.webView = nil
    end
    if (self.group) then
        self.group:removeSelf()
        self.group = nil
    end
end

return CBWebViewProtocol