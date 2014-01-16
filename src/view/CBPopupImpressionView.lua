--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create display groups that hold all impression views.
-- Instantiate using CBPopupImpressionView(cbProxy)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBBackgroundView = require "chartboost.view.CBBackgroundView"

local CBPopupImpressionView = class(function(self, cbProxy, content)
    self.cbProxy = cbProxy
    assert(type(content) == "table", "Second parameter 'reversed' must be a DisplayObject.")
    self.group = display.newGroup()

    local dif = cbProxy.getForcedOrientationDifference()
    local w, h = dif.flipIfOdd(display.contentWidth, display.contentHeight)

    -- block clicks
    self.clickBlocker = display.newRect(0, 0, w, h)
    self.clickBlocker.alpha = 0
    self.clickBlocker.isHitTestable = true -- Only needed if alpha is 0
    self.clickBlocker:addEventListener("touch", function() return true end)
    self.clickBlocker:addEventListener("tap", function() return true end)
    self.clickBlocker.x = display.contentCenterX; self.clickBlocker.y = display.contentCenterY
    self.group:insert(self.clickBlocker)

    self.content = content
    self.backgroundView = CBBackgroundView(self.cbProxy)
    self.group:insert(self.backgroundView.group)
    self.group:insert(self.content.group)

    local function updateWindow()
        self.lastOrientationDiff = self.cbProxy.getForcedOrientationDifference()
        self.lastOrientation = self.cbProxy.getOrientation()
        self.group.rotation = self.lastOrientationDiff.diff
        if self.group.rotation == 90 then
            self.group.x = display.contentCenterX + display.contentHeight/2 - (display.contentHeight - display.contentWidth) /2
            self.group.y = display.contentCenterY - display.contentWidth/2 - (display.contentHeight - display.contentWidth) /2
        elseif self.group.rotation == 180 then
            self.group.x = display.contentCenterX + display.contentWidth/2
            self.group.y = display.contentCenterY + display.contentHeight/2
        elseif self.group.rotation == 270 then
            self.group.x = display.contentCenterX - display.contentHeight/2 + (display.contentHeight - display.contentWidth)/2
            self.group.y = display.contentCenterY + display.contentWidth/2 + (display.contentHeight - display.contentWidth) /2
        else
            self.group.x = display.contentCenterX - display.contentWidth/2
            self.group.y = display.contentCenterY - display.contentHeight/2
        end
    end
    updateWindow()
    self.onOrientationChange = function(orientation)
        local orientationDiff = self.cbProxy.getForcedOrientationDifference()
        local orientation = self.cbProxy.getOrientation()
        if (self.lastOrientationDiff == orientationDiff and self.lastOrientation == orientation) then
            return
        end
        updateWindow()
        local w, h = orientationDiff.flipIfOdd(display.contentWidth, display.contentHeight)
        self.clickBlocker.width, self.clickBlocker.height = w, h
        self.backgroundView:onViewUpdateRequired()
        self.content:onViewUpdateRequired()
    end
    -- Runtime:addEventListener("orientation", self.onOrientationChange)

    -- Key listener
    self.onKeyEvent = function(event)
        local phase = event.phase
        local keyName = event.keyName
        print("KEY PRESS: ("..phase.." , " .. keyName ..")")

        if keyName == "back" then
            if phase == "up" then
                 self.content.viewProtocol.viewProtocol.closeCallback()
            end
            return true
        end
        return false
    end

    -- Add the key callback
    Runtime:addEventListener("key", self.onKeyEvent);
end)

function CBPopupImpressionView:addToStage()
    -- nothing currently. it's already there
end

function CBPopupImpressionView:removeFromStage()
    self:destroy()
end

function CBPopupImpressionView:destroy()
    Runtime:removeEventListener("orientation", self.onOrientationChange)
    Runtime:removeEventListener("key", self.onKeyEvent)
    if self.content and self.content.group then -- shouldn't ever be true
        self.content.group:removeSelf()
        self.content = nil
    end
    if self.backgroundView then
        self.backgroundView:destroy()
        self.backgroundView = nil
    end
    if self.group then
        self.group:removeSelf()
        self.group = nil
    end
end

return CBPopupImpressionView