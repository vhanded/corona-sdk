--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is the common functionality used to create and manage the impression views.
-- Instantiate using CBViewProtocol(CBImpression, createViewObject, imageCount)
--   Call method 'protocol:prepareWithResponse(table)' begin the process of creating
--     the impression, passing in the json data from the server
--   Call method 'protocol:destroy()' to remove the view from the stage and perform cleanup
--
-- Internally, the class CBBaseView is provides common functionality for the actual views.
-- Instantiate using CBBaseView(subclass object)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:tryLayout()' to initialize the view's content
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBWebImageCache = require "chartboost.networking.CBWebImageCache"
local CBImpressionState = require "chartboost.model.CBImpressionState"

--- params: self, CBImpression, function that returns a chartboost.view object, expected image count
local CBViewProtocol = class(function(self, impression, createViewObject, imageCount)
    assert(type(impression) == "table", "First parameter 'impression' must be a CBImpression.")
    assert(type(createViewObject) == "function", "Second parameter 'createViewObject' must be a function that returns a chartboost.view object.")
    assert(type(imageCount) == "number", "Third parameter 'imageCount' must be a number.")
    self.impression = impression
    self.view = nil
    self.expectedImagesCount = imageCount
    self.createViewObject = createViewObject
end)

function CBViewProtocol:prepareWithResponse(response)
    assert(type(response) == "table", "First parameter 'response' must be a table.")
    self.loadedCount = 0
    self.imagesToLoad = 0
    self.processedCount = 0
    self.assets = response["assets"]
    if self.assets == nil then
        if self.failCallback then
            self.failCallback("chartboost response missing assets information")
        end
        return
    end
end
--- params: string, CBWebImageProtocol, boolean or nil
function CBViewProtocol:PROCESS_LOADING_ASSET(key, callback, doNotCacheInMemory)
    assert(type(key) == "string", "First parameter 'key' must be a string.")
    assert(type(callback) == "function", "Second parameter 'callback' must be a function or nil.")
    doNotCacheInMemory = doNotCacheInMemory or false
    assert(type(doNotCacheInMemory) == "boolean", "Third parameter 'doNotCacheInMemory' must be a boolean or nil.")
    local data = {[CBWebImageCache.PARAM_NO_MEMORY_CACHE] = doNotCacheInMemory}
    self:PROCESS_LOADING_ASSET_IMPL(key, callback, data)
end

--- params: string, CBWebImageProtocol, boolean or nil, table
function CBViewProtocol:PROCESS_LOADING_ASSET_IMPL(key, callback, data, assetsObject)
    assetsObject = assetsObject or self.assets
    assert(type(key) == "string", "First parameter 'key' must be a string.")
    assert(type(callback) == "function", "Second parameter 'callback' must be a function or nil.")
    assert(type(data) == "table", "Third parameter 'data' must be a table or nil.")
    assert(type(assetsObject) == "table", "Fourth parameter 'assetsObject' must be a table or nil.")
    local propInfo = assetsObject[key]
    if propInfo then
        self.imagesToLoad = self.imagesToLoad + 1
        local propUrl = propInfo["url"]
        local propChecksum = propInfo["checksum"]
        self.impression.cbProxy.getImageCache():loadImageWithURL(propUrl, propChecksum, callback, data)
    else
        self:onBitmapLoaded(nil)
    end
end

--- Called every time a bitmap is loaded (from the internet or a memory/file cache).
--- When all bitmaps to be loaded have been processed (successfully or not), the signal
--- is given to either show the impression (all bitmaps successful) or trigger an error.
function CBViewProtocol:onBitmapLoaded(bitmap)
    if bitmap then
        assert(type(bitmap) == "table", "First parameter 'bitmap' must be a table that is callable and creates and returns a DisplayObject.")
        assert(type(getmetatable(bitmap).__call) == "function", "First parameter 'bitmap' must be a table that is callable and creates and returns a DisplayObject.")
        self.loadedCount = self.loadedCount + 1
    end
    self.processedCount = self.processedCount + 1
    --print ("CBViewProtocol:onBitmapLoaded " .. self.loadedCount .. " = max(" .. self.imagesToLoad .. "," .. self.expectedImagesCount .. ")?")
    if self.processedCount == self.expectedImagesCount then
        if self:setReadyToDisplay() then
            return
        end

        if self.failCallback ~= nil then
            self.failCallback("chartboost view not ready to display")
        end
    end
end

--- creates the actual chartboost.view, returns whether or not it was successful
--- (or successfully cached or waiting for a valid activity)
function CBViewProtocol:setReadyToDisplay()
    if (self.loadedCount ~= self.imagesToLoad) then
        return false
    end

    --print ("CBViewProtocol:setReadyToDisplay")

    if (self.displayCallback) then
        self.displayCallback()
    end

    return true
end

--- attempt to create the chartboost.view associated with self chartboost.view protocol's impression.
--- fails if it is not time to create the chartboost.view, or there was an error trying to
--- create the chartboost.view (no current activity, for example)
--- return true if successful, false if not
function CBViewProtocol:createView()
    if (self.impression.state ~= CBImpressionState.CBImpressionStateWaitingForDisplay) then
        return false, "impression was not waiting for display"
    end

    -- indicate self is a chartboost.view that needs to be displayed upon activity startup
    -- there is no "activity" startup in corona so currently this is only used by tests
    self.impression.cbProxy.setActiveImpression(self.impression)

    self.view = self.createViewObject()

    local success, error = self.view.viewBase:tryLayout()
    if success then
        return true
    else
        self.view = nil
        return false, error
    end
end

-- create the actual chartboost.view object
-- createViewObject() is a var passed in

-- clean up the chartboost view and its data
-- self calls through to #destroyView()
function CBViewProtocol:destroy()
    self:destroyView()
    self.displayCallback = nil
    self.failCallback = nil
    self.clickCallback = nil
    self.closeCallback = nil
    self.assets = nil
end

-- clean up the chartboost view (not its data)
function CBViewProtocol:destroyView()
    if self.view then
        self.view:destroy()
    end
    self.view = nil
end


-- we've separated the actual chartboost view into a separate class so that we don't
-- create it until all of the assets are loaded. this way we can create it
-- in a new activity if eg there was a config change during loading.

local CBViewBase = class(function(self, viewImpl)
    assert(type(viewImpl) == "table", "First parameter 'viewImpl' must be a CBViewBase subclass.")
    self.ignore = false
    self.viewImpl = viewImpl
    self.viewImpl.onViewUpdateRequired = function()
        self:onViewUpdateRequired()
    end
    -- removed: create a touch barrier
end)

function CBViewBase:onSizeChanged(w, h)
    assert(type(w) == "number", "First parameter 'w' must be a number.")
    assert(type(h) == "number", "Second parameter 'h' must be a number.")
    if self.ignore then return end

    local orDiff = self.viewImpl.viewProtocol.viewProtocol.impression.cbProxy.getForcedOrientationDifference()
    w, h = orDiff.flipIfOdd(w, h)
    self:tryLayout(w, h)
end

function CBViewBase:tryLayout(w, h)
    if not w or not h then
        -- get initial dimensions
        local orDiff = self.viewImpl.viewProtocol.viewProtocol.impression.cbProxy.getForcedOrientationDifference()
        w, h = orDiff.flipIfOdd(display.contentWidth, display.contentHeight)
    end
    assert(type(w) == "number", "First parameter 'w' must be a number.")
    assert(type(h) == "number", "Second parameter 'h' must be a number.")

    local success, error = pcall(self.viewImpl.layoutSubviews, self.viewImpl, w, h)
    if success then
        return true
    else
        -- UNCOMMENT THIS TO HELP WITH DEBUGGING!
        -- print("Error creating layout for impression: " .. error)
        return false, error
    end
end

function CBViewBase:onViewUpdateRequired()
    self:tryLayout()
end

function CBViewBase:destroy()
    --
end

return {CBViewProtocol, CBViewBase}