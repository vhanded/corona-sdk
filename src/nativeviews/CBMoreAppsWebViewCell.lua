--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class wraps the creation of webview cells for the more apps page
-- Instantiate using CBMoreAppsWebViewCell(cbProxy, cellMeta, position, onClick)
-- Call cell:getCell() to get the actual table to supply to the tableview widget.
--

local class = require "chartboost.libraries.lib.class"
local CBUtility = require "chartboost.libraries.CBUtility"
local CBMoreAppsCell = require "chartboost.nativeviews.CBMoreAppsCell"

local CBMoreAppsWebViewCell = class(function(self, cbProxy, cellMeta, position, onClick)
    assert(type(cbProxy) == "table", "First parameter 'cbProxy' must be a CBProxy.")
    self.cbProxy = cbProxy
    assert(type(cellMeta) == "table", "Second parameter 'cellMeta' must be a table.")
    assert(type(position) == "number", "Third parameter 'position' must be a number.")
    assert(type(onClick) == "function", "Fourth parameter 'onClick' must be a function.")
    local height = CBUtility.dpToPixels(100)
    self.cell = CBMoreAppsCell.baseCell(height, onClick)
    self.cell.onRender = function(event)
        -- no need to save old onRender and call it here as we don't need a background
        local row = event.row
        local rowGroup = event.row

        local HTML_FILENAME = "tempWebViewCell_"..tostring(position)..".html"
        self.html = cellMeta["html"]
        if not self.html then return end -- html invalid for some reason

        local htmlFile = system.pathForFile(HTML_FILENAME , system.TemporaryDirectory)
        local file = io.open(htmlFile, "w")
        file:write(self.html)
        io.close(file)
        file = nil

        local function webListener(event)
            local url = event.url

            -- Make sure its a valid request
            if not url then return false end

            -- Handle chartboost: urls.
            if url:find("chartboost") and url:find("click") then
                onClick()
            end
            return true
        end

        local webView = native.newWebView(0, 0, row.width, row.height, webListener)
        webView:request(HTML_FILENAME , system.TemporaryDirectory)
        -- TODO: how to make system.ResourceDirectory the base directory??
        webView:addEventListener("urlRequest", webListener)
        self.webView = webView
        rowGroup:insert(webView)
    end
end)

function CBMoreAppsWebViewCell:getCell()
    return self.cell
end

return CBMoreAppsWebViewCell
