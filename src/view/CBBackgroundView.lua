--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create a background view.
-- Instantiate using CBBackgroundView(cbProxy)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local kCBAnimationDuration = 255

local CBBackgroundView = class(function(self, cbProxy)
    self.gradientReversed = false
    self.cbProxy = cbProxy

    self.group = display.newGroup()
    self:tryLayout()
end)

function CBBackgroundView:onViewUpdateRequired()
    self:tryLayout()
end

function CBBackgroundView:tryLayout()
    local dif = self.cbProxy.getForcedOrientationDifference()
    local w, h = dif.flipIfOdd(display.actualContentWidth, display.actualContentHeight)
    if self.backgroundView then self.backgroundView:removeSelf() end
    self.backgroundView = display.newRect(0, 0, w, h)
    self.backgroundView:setFillColor(0, 0, 0, 0xA0/255)
    self.group:insert(self.backgroundView)
    self.backgroundView.x = display.contentCenterX; self.backgroundView.y = display.contentCenterY;
end

function CBBackgroundView:destroy()
    if self.backgroundView then
        self.backgroundView:removeSelf()
        self.backgroundView = nil
    end
    if self.group then
        self.group:removeSelf()
        self.group = nil
    end
end

--- fade in a given chartboost view, usually a child
function CBBackgroundView:fadeIn(fadeView)
    fadeView = fadeView or self.backgroundView
    assert(type(fadeView) == "table", "First parameter 'fromX' must be a DisplayObject or nil.")
    fadeView.alpha = 0
    transition.to(fadeView, {time = kCBAnimationDuration * 2, alpha = 1})
end

function CBBackgroundView:setGradientReversed(rev)
    assert(type(rev) == "boolean", "First parameter 'reversed' must be a boolean.")
    self.gradientReversed = rev
    --self:prepareBackground()
end

      --[[
-- this is unfinished code for making this background a subtle radial gradient,
--   but if there is no way to do it in corona without
--   an image (included or downloaded), then it's not worth it
function CBBackgroundView:onSizeChanged(w, h)
    self:prepareBackground()
end

function CBBackgroundView:prepareBackground()
    local edgeColor, centerColor
    if gradientReversed then
        edgeColor = 0x88000000
        centerColor = 0xCC000000
    else
        edgeColor = 0xCC000000
        centerColor = 0x88000000
    end

    local radius = math.min(display.contentWidth, display.contentHeight);
    -- TO-DO: make a radial gradient, properly set size above
end  --]]

return CBBackgroundView