--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create and manage the more apps impression.
-- Instantiate using CBMoreAppsViewProtocol(CBImpression)
--   Call method 'protocol:prepareWithResponse(table)' begin the process of creating
--     the impression, passing in the json data from the server
--   Call method 'protocol:destroy()' to remove the view from the stage and perform cleanup
--
-- Internally, the class CBMoreAppsView is used to create the actual more apps view.
-- Instantiate using CBMoreAppsView(CBMoreAppsViewProtocol)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:layoutSubviews(width, height)' to initialize the view's content
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBViewProtocol, CBViewBase = unpack(require "chartboost.CBViewProtocol")
local CBMoreAppsRegularCell = require "chartboost.nativeviews.CBMoreAppsRegularCell"
local CBMoreAppsFeaturedCell = require "chartboost.nativeviews.CBMoreAppsFeaturedCell"
local CBMoreAppsWebViewCell = require "chartboost.nativeviews.CBMoreAppsWebViewCell"
local CBUtility = require "chartboost.libraries.CBUtility"

local widget = require "widget"
local TABLE_BGCOLOR = {0xE3, 0xE3, 0xE3, 255}

local kCBNativeMoreAppsHeaderHeight = CBUtility.dpToPixels(50)
local kCBNativeMoreAppsCloseButtonWidth = CBUtility.dpToPixels(50)
local kCBNativeMoreAppsCloseButtonHeight = CBUtility.dpToPixels(30)


local CBMoreAppsView = class(function(self, nativeViewProtocol)
    assert(type(nativeViewProtocol) == "table", "First parameter 'viewProtocol' must be a table.")
    self.viewProtocol = nativeViewProtocol
    self.viewBase = CBViewBase(self)

    self.group = display.newGroup()
end)

--- params: self, CBImpression
local CBMoreAppsViewProtocol = class(function(self, impression)
    assert(type(impression) == "table", "First parameter 'impression' must be a table.")
    self.viewProtocol = CBViewProtocol(impression, function()
        self.view = CBMoreAppsView(self)
        return self.view
    end, 3)
    self.cells = {}
end)

function CBMoreAppsViewProtocol:prepareWithResponse(response)
    assert(type(response) == "table", "First parameter 'response' must be a table.")
    self.viewProtocol:prepareWithResponse(response)

    local cellsMeta = response["cells"]
    if not cellsMeta then
        if self.viewProtocol.viewProtocol.failCallback then
            self.viewProtocol.viewProtocol.failCallback("chartboost response missing more app cells information")
        end
        return
    end

    -- first load the icons as there are an unknown number of them
    -- and we need to update self.expectedImagesCount along the way
    self.iconImages = {}
    local cbIcons = function(bitmap, data)
        self.iconImages[data["index"]] = bitmap
        self.viewProtocol:onBitmapLoaded(bitmap)
    end

    -- preload any other image assets in the list of apps
    for i,cellMeta in pairs(cellsMeta) do
        self.cells[#self.cells + 1] = cellMeta

        local type = cellMeta["type"]
        if type == "regular" then
            local assets = cellMeta["assets"]
            if assets then
                self.viewProtocol.expectedImagesCount = self.viewProtocol.expectedImagesCount + 1
                local data = {index = i}
                self.viewProtocol:PROCESS_LOADING_ASSET_IMPL("icon", cbIcons, data, assets)
            end
        elseif type == "featured" then
            local assets = cellMeta["assets"]
            if assets then
                self.viewProtocol.expectedImagesCount = self.viewProtocol.expectedImagesCount + 1
                local data = {index = i}
                self.viewProtocol:PROCESS_LOADING_ASSET_IMPL("portrait", cbIcons, data, assets)

                self.viewProtocol.expectedImagesCount = self.viewProtocol.expectedImagesCount + 1
                local data2 = {index = i}
                self.viewProtocol:PROCESS_LOADING_ASSET_IMPL("landscape", cbIcons, data2, assets)
            end
        elseif type == "webview" then
            --
        end
    end

    local cb1 = function(bitmap, data) self.closeImage = bitmap self.viewProtocol:onBitmapLoaded(bitmap) end
    local cb2 = function(bitmap, data) self.headerImage = bitmap self.viewProtocol:onBitmapLoaded(bitmap) end
    local cb3 = function(bitmap, data) self.headerTileImage = bitmap self.viewProtocol:onBitmapLoaded(bitmap) end

    self.viewProtocol:PROCESS_LOADING_ASSET("close", cb1)
    self.viewProtocol:PROCESS_LOADING_ASSET("header-center", cb2)
    self.viewProtocol:PROCESS_LOADING_ASSET("header-tile", cb3)
end

-- create the actual chartboost.view object
-- createViewObject() is a var passed in

-- clean up the chartboost view and its data
-- self calls through to #destroyView()
function CBMoreAppsViewProtocol:destroy()
    self.viewProtocol:destroy()

    self.cells = nil
    self.closeImage = nil
    self.headerTileImage = nil
    self.headerImage = nil
end

-- clean up the chartboost view (not its data)
function CBMoreAppsViewProtocol:destroyView()
    -- nothing to do here
end


function CBMoreAppsView:layoutSubviews(w, h)
    assert(type(w) == "number", "First parameter 'w' must be a number.")
    assert(type(h) == "number", "Second parameter 'h' must be a number.")
    local cbProxy = self.viewProtocol.viewProtocol.impression.cbProxy
    local dif = cbProxy.getForcedOrientationDifference()

    -- Handle row rendering
    local function onRowRender(event)
        local index = event.row.index
        self.rowList[index].onRender(event)
    end

    -- Handle touches on the row
    local function onRowTouch(event)
        local index = event.target.index

        if index then -- good way to filter out swipeRight/swipeLeft event.phase
            self.rowList[index].onTouch(event)
        end
    end

    if self.tableView then
        self.tableView:removeSelf()
    end
    self.tableView = widget.newTableView{
        top = kCBNativeMoreAppsHeaderHeight,
        width = w,
        height = h - kCBNativeMoreAppsHeaderHeight,
        backgroundColor = TABLE_BGCOLOR,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch
    }

    local insertRow = self.tableView.insertRow
    self.rowList = {}
    local rowList = self.rowList
    self.tableView.insertRow = function(self, row)
        rowList[self:getNumRows() + 1] = row
        insertRow(self, row)
    end

    -- Modify listener to allow scrolling when rotated
    local cbProxy = self.viewProtocol.viewProtocol.impression.cbProxy
    local pi, cos, sin = math.pi, math.cos, math.sin
    local function fixEvent(event)
        local x1, x2, y1, y2 = event.xStart, event.x, event.yStart, event.y
        local dif = cbProxy.getForcedOrientationDifference()
        local theta = -(pi * dif.diff) / 180
        local xc, yc = w / 2, kCBNativeMoreAppsHeaderHeight + (h - kCBNativeMoreAppsHeaderHeight) / 2
        if x1 and y1 then
            local x, y = x1 - xc, y1 - yc
            x1, y1 = x*cos(theta) - y*sin(theta) + xc, x*sin(theta) + y*cos(theta) + yc
        end
        if x2 and y2 then
            local x, y = x2 - xc, y2 - yc
            x2, y2 = x*cos(theta) - y*sin(theta) + xc, x*sin(theta) + y*cos(theta) + yc
        end
        event.xStart, event.x, event.yStart, event.y = x1, x2, y1, y2
        return event
    end

    local function wrapListener(setter, getter)
        local method = getter()
        if method then
            local listener = function(content, event)
                method(content, fixEvent(event))
            end
            setter(listener)
        end
    end

    -- TODO: when this view is rotated due to an orientation difference, scrolling gets a little funky
    wrapListener(function(l) self.tableView._view.touch = l end,
        function() return self.tableView._view.touch end)
    wrapListener(function(l) self.tableView._view._background.touch = l end,
        function() return self.tableView._view._background.touch end)

    -- Create rows in the tableView
    for position, cellMeta in ipairs(self.viewProtocol.cells) do
        local type = cellMeta["type"] or ""
        local moreAppCellView

        local clickListener = function()
            local url = cellMeta["deep-link"]
            if not url or url == "" then
                url = cellMeta["link"]
            end
            if self.viewProtocol.viewProtocol.clickCallback then
                self.viewProtocol.viewProtocol.clickCallback(url, cellMeta)
            end
        end

        if type == "featured" then
            moreAppCellView = CBMoreAppsFeaturedCell(cbProxy, cellMeta, position, clickListener)
        elseif type == "regular" then
            moreAppCellView = CBMoreAppsRegularCell(cbProxy, cellMeta, position, clickListener)
        elseif type == "webview" then
            moreAppCellView = CBMoreAppsWebViewCell(cbProxy, cellMeta, position, clickListener)
        end

        self.tableView:insertRow(moreAppCellView:getCell())
    end
    self.group:insert(self.tableView)

    -- title
    if not self.titleViewBG then
        self.titleViewBG = self.viewProtocol.headerTileImage()
        self.group:insert(self.titleViewBG)
    end
    self.titleViewBG.yScale = kCBNativeMoreAppsHeaderHeight / self.titleViewBG.height
    self.titleViewBG.xScale = w / self.titleViewBG.width
    self.titleViewBG.x = w / 2
    self.titleViewBG.y = (kCBNativeMoreAppsHeaderHeight) / 2
    self.titleViewBG:toFront()

    if not self.titleView then
        self.titleView = self.viewProtocol.headerImage()
        self.group:insert(self.titleView)
        self.titleView.yScale = math.min(1, kCBNativeMoreAppsHeaderHeight / self.titleView.height)
        self.titleView.xScale = self.titleView.yScale
    end
    self.titleView.x = w * 0.5
    self.titleView.y = (kCBNativeMoreAppsHeaderHeight) / 2
    self.titleView:toFront()

    -- close button
    if not self.closeButton then
        self.closeButton = self.viewProtocol.closeImage()
        self.group:insert(self.closeButton)
        self.closeButton.xScale = kCBNativeMoreAppsCloseButtonWidth / self.closeButton.width
        self.closeButton.yScale = kCBNativeMoreAppsCloseButtonHeight / self.closeButton.height

        self.closeButton:addEventListener("tap", function(event)
            local onClick = self.viewProtocol.viewProtocol.closeCallback
            if onClick then
                onClick()
            end
            return true
        end)
    end
    self.closeButton.x = w - CBUtility.dpToPixels(10) - self.closeButton.xScale * self.closeButton.width * 0.5
    self.closeButton.y = (kCBNativeMoreAppsHeaderHeight - kCBNativeMoreAppsCloseButtonHeight) / 2
            + self.closeButton.yScale * self.closeButton.height * 0.5
    self.closeButton:toFront()
end

function CBMoreAppsView:destroy()
    self.viewBase:destroy()
    if (self.titleView) then
        self.titleView:removeSelf()
        self.titleView = nil
    end
    if (self.titleViewBG) then
        self.titleViewBG:removeSelf()
        self.titleViewBG = nil
    end
    if (self.closeButton) then
        self.closeButton:removeSelf()
        self.closeButton = nil
    end
    if (self.tableView) then
        self.tableView:removeSelf()
        self.tableView = nil
    end
    if (self.group) then
        self.group:removeSelf()
        self.group = nil
    end
end

return CBMoreAppsViewProtocol