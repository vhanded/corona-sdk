--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create a loading status view.
-- Instantiate using CBLoadingView(cbProxy)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBUnderfinedProgressBar = require "chartboost.view.CBUnderfinedProgressBar"
local CBUtility = require "chartboost.libraries.CBUtility"

local CBLoadingView = class(function(self, cbProxy)
    self.group = display.newGroup()
    self.cbProxy = cbProxy
    self:tryLayout()
end)

function CBLoadingView:onViewUpdateRequired()
    self:tryLayout()
end

function CBLoadingView:tryLayout()
    local dif = self.cbProxy.getForcedOrientationDifference()
    local w, h = dif.flipIfOdd(display.contentWidth, display.contentHeight)

    local density = CBUtility.dpToPixels(1)
    local margin = 20 * density

    if not self.label then
        self.label = display.newText("Loading...", 0, 0, native.systemFontBold, 18)
        self.group:insert(self.label)
        -- self.label:setReferencePoint(display.CenterReferencePoint)
        self.label.anchorX = 0.5; self.label.anchorY = 0.5;
        self.label:setTextColor(255/255, 255/255, 255/255, 255/255)
    end
    self.label.x = w*0.5;
    self.label.y = h*0.5 - margin * 0.65

    if self.progressBar then self.progressBar.group:removeSelf() end
    self.progressBar = CBUnderfinedProgressBar(margin, h * 0.5 + margin * 0.65,
        w - margin * 2, 32 * density)
    self.group:insert(self.progressBar.group)
end

function CBLoadingView:destroy()
    if self.label then
        self.label:removeSelf()
        self.label = nil
    end
    if self.progressBar then
        self.progressBar:destroy()
        self.progressBar = nil
    end
    if self.group then
        self.group:removeSelf()
        self.group = nil
    end
end

return CBLoadingView