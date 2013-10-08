--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create and manage the more apps impression.
-- Instantiate using CBNativeInterstitialViewProtocol(CBImpression)
--   Call method 'protocol:prepareWithResponse(table)' begin the process of creating
--     the impression, passing in the json data from the server
--   Call method 'protocol:destroy()' to remove the view from the stage and perform cleanup
--
-- Internally, the class CBMoreAppsView is used to create the actual more apps view.
-- Instantiate using CBNativeInterstitialView(CBNativeInterstitialViewProtocol)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:layoutSubviews(width, height)' to initialize the view's content
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBViewProtocol, CBViewBase = unpack(require "chartboost.CBViewProtocol")
local CBUtility = require "chartboost.libraries.CBUtility"

local CBNativeInterstitialView = class(function(self, nativeViewProtocol)
    assert(type(nativeViewProtocol) == "table", "First parameter 'viewProtocol' must be a table.")
    self.viewProtocol = nativeViewProtocol
    self.viewBase = CBViewBase(self)

    self.group = display.newGroup()
end)

--- params: self, CBImpression
local CBNativeInterstitialViewProtocol = class(function(self, impression)
    assert(type(impression) == "table", "First parameter 'impression' must be a table.")
    self.viewProtocol = CBViewProtocol(impression, function()
        self.view = CBNativeInterstitialView(self)
        return self.view
    end, 5)
end)

function CBNativeInterstitialViewProtocol:prepareWithResponse(response)
    assert(type(response) == "table", "First parameter 'response' must be a table.")
    self.viewProtocol:prepareWithResponse(response)

    local cb1 = function(bitmap, data) self.adImageLandscape = bitmap; self.viewProtocol:onBitmapLoaded(bitmap) end
    local cb2 = function(bitmap, data) self.adImagePortrait = bitmap; self.viewProtocol:onBitmapLoaded(bitmap) end
    local cb3 = function(bitmap, data) self.frameImageLandscape = bitmap; self.viewProtocol:onBitmapLoaded(bitmap) end
    local cb4 = function(bitmap, data) self.frameImagePortrait = bitmap; self.viewProtocol:onBitmapLoaded(bitmap) end
    local cb5 = function(bitmap, data) self.closeImage = bitmap; self.viewProtocol:onBitmapLoaded(bitmap) end

    self.viewProtocol:PROCESS_LOADING_ASSET("ad-landscape", cb1, true)
    self.viewProtocol:PROCESS_LOADING_ASSET("ad-portrait", cb2, true)
    self.viewProtocol:PROCESS_LOADING_ASSET("frame-landscape",cb3)
    self.viewProtocol:PROCESS_LOADING_ASSET("frame-portrait", cb4)
    self.viewProtocol:PROCESS_LOADING_ASSET("close", cb5)
end

-- create the actual chartboost view object
-- createViewObject() is a var passed in

-- clean up the chartboost view and its data
-- self calls through to #destroyView()
function CBNativeInterstitialViewProtocol:destroy()
    self.viewProtocol:destroy()

    self.adImageLandscape = nil
    self.adImagePortrait = nil
    self.frameImageLandscape = nil
    self.frameImagePortrait = nil
    self.closeImage = nil
end

-- clean up the chartboost view (not its data)
function CBNativeInterstitialViewProtocol:destroyView()
    -- nothing to do here
end


function CBNativeInterstitialView:layoutSubviews(w, h)
    assert(type(w) == "number", "First parameter 'w' must be a number.")
    assert(type(h) == "number", "Second parameter 'h' must be a number.")
    local cbProxy = self.viewProtocol.viewProtocol.impression.cbProxy
    local orientation = cbProxy.getOrientation()
    local isPortrait = orientation.isPortrait()

    local adImage, frameImage, scale, key
    if isPortrait then
        adImage = self.viewProtocol.adImagePortrait
        frameImage = self.viewProtocol.frameImagePortrait
        scale = math.max(320.0/w, 480.0/h)
        key = "portrait"
    else
        adImage = self.viewProtocol.adImageLandscape
        frameImage = self.viewProtocol.frameImageLandscape
        scale = math.max(320.0/h, 480.0/w)
        key = "landscape"
    end

    -- frame
    if self.frame then self.frame:removeSelf() end
    self.frame = frameImage()
    self.group:insert(self.frame)
    self.frame.xScale = 1.0 / scale
    self.frame.yScale = 1.0 / scale
    local frameOffset = self:getOffset("frame-" .. key)
    self.frame.x = (w - self.frame.contentWidth * self.frame.xScale) / 2.0
            + frameOffset.x / scale + (self.frame.contentWidth * self.frame.xScale / 2.0)
    self.frame.y = (h - self.frame.contentHeight * self.frame.yScale) / 2.0
            + frameOffset.x / scale + (self.frame.contentHeight * self.frame.yScale / 2.0)

    -- ad image
    if self.adUnit then self.adUnit:removeSelf() end
    self.adUnit = adImage()
    self.group:insert(self.adUnit)
    self.adUnit.xScale = 1.0 / scale
    self.adUnit.yScale = 1.0 / scale
    local adOffset = self:getOffset("ad-" .. key)
    self.adUnit.x = (w - self.adUnit.contentWidth * self.adUnit.xScale) / 2.0
            + adOffset.x / scale + (self.adUnit.contentWidth * self.adUnit.xScale / 2.0)
    self.adUnit.y = (h - self.adUnit.contentHeight * self.adUnit.yScale) / 2.0
            + adOffset.x / scale + (self.adUnit.contentHeight * self.adUnit.yScale / 2.0)

    self.adUnit:addEventListener("tap", function(event)
        local onClick = self.viewProtocol.viewProtocol.clickCallback
        if onClick then
            onClick(nil, nil)
        end
        return true
    end)

    -- close button
    if self.closeButton then
        self.closeButton:removeSelf()
    end
    self.closeButton = self.viewProtocol.closeImage()
    self.group:insert(self.closeButton)
    self.closeButton.xScale = 1.0 / scale
    self.closeButton.yScale = 1.0 / scale

    self.closeButton:addEventListener("tap", function(event)
        local onClick = self.viewProtocol.viewProtocol.closeCallback
        if onClick then
            onClick()
        end
        return true
    end)
    self.closeButton:toFront()
    local closeOffset = self:getOffset("close")
    self.closeButton.x = self.adUnit.x + (self.adUnit.width * self.adUnit.xScale) / 2.0
            + closeOffset.x / scale - CBUtility.dpToPixels(10) + (self.closeButton.width * self.closeButton.xScale / 2.0)
    self.closeButton.y = self.adUnit.y - (self.adUnit.height * self.adUnit.yScale) / 2.0
            - (self.closeButton.height * self.closeButton.yScale) + closeOffset.y / scale - CBUtility.dpToPixels(10)
            + (self.closeButton.height * self.closeButton.yScale / 2.0)
end

function CBNativeInterstitialView:destroy()
    self.viewBase:destroy()
    if (self.adUnit) then
        self.adUnit:removeSelf()
        self.adUnit = nil
    end
    if (self.closeButton) then
        self.closeButton:removeSelf()
        self.closeButton = nil
    end
    if (self.frame) then
        self.frame:removeSelf()
        self.frame = nil
    end
    if (self.group) then
        self.group:removeSelf()
        self.group = nil
    end
end

function CBNativeInterstitialView:getOffset(param)
    local marginObj = self.viewProtocol.viewProtocol.assets[param]
    if marginObj then
        local offsetObj = marginObj["offset"]
        if offsetObj then
            return {x = offsetObj["x"] or 0,
                    y = offsetObj["y"] or 0}
        end
    end
    return {x = 0, y = 0}
end

return CBNativeInterstitialViewProtocol