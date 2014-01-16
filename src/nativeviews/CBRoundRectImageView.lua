--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create an outlined round rect version of an icon, used in the more apps page.
-- Instantiate using CBRoundRectImageView(cbProxy, bitamp)
--                     -- the final param is a table that creates and returns a display object when called
--                     --   (therefore it must be callable, set using its metatable)
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBUtility = require "chartboost.libraries.CBUtility"

--local STROKE_ALPHA = 0xA6 --using alpha doesn't seem to look too good for corona
local STROKE_WIDTH = math.max(1, CBUtility.dpToPixels(3))  -- at least 1px even on small screens
local CORNER_RADIUS = CBUtility.dpToPixels(10)


-- TODO: currently this only works right for square images, let's fix that!
-- it would be great if we had 9-patch capabilities for the mask

local CBRoundRectImageView = class(function(self, cbProxy, bitmap)
    assert(type(bitmap) == "table", "Second parameter 'bitmap' must be a callable table that creates and returns a display object.")
    self.group = display.newGroup()
    self.image = bitmap()
    self.group:insert(self.image)
    self.outline = display.newRoundedRect(self.group, 0, 0,
        self.image.contentWidth, self.image.contentHeight, CORNER_RADIUS)
    self.outline.strokeWidth = STROKE_WIDTH
    self.outline:setStrokeColor(0, 0, 0, 255)
    self.outline:setFillColor(0, 0, 0, 0)
    --[[
    -- this mask approach didn't seem to work to well
    -- maybe it could be fixed up someday
      self:createMaskFile(function(name)
          self.imageMask = graphics.newMask(name, system.TemporaryDirectory)
          self.group:setMask(self.imageMask)
          self.group:setReferencePoint(display.CenterReferencePoint)
          self.group.maskX = self.group.x
          self.group.maskY = self.group.y
      end)  --]]
    local file_name = cbProxy.getPackagedImageFileName("__chartboost_rr.png")
    self.imageMask = graphics.newMask(file_name, system.ResourceDirectory)
    self.image:setMask(self.imageMask)
    -- self.image:setReferencePoint(display.CenterReferencePoint)\
    self.image.anchorX = 0.5; self.image.anchorY = 0.5;
    local ratio = 1 --120.0 / 114.0 -- image is 120px square with a 3px border
    self.image.maskScaleX = ratio * self.image.contentWidth / 114
    self.image.maskScaleY = ratio * self.image.contentHeight / 114
    self.image.maskX = self.group.x
    self.image.maskY = self.group.y
end)
           --[[
           -- unused masking related functions
function CBRoundRectImageView:createMaskFile(finish)
    local margin = 3
    local group = display.newGroup()
    local width = math.ceil((self.image.contentWidth + margin * 2) / 4.0) * 4
    local height = math.ceil((self.image.contentHeight + margin * 2) / 4.0) * 4
    --local black = display.newRect(group, 0, 0, width, height)
    local white = display.newRoundedRect( (width - self.image.contentWidth) / 2.0,
        (height - self.image.contentHeight) / 2.0, self.image.contentWidth, self.image.contentHeight, CORNER_RADIUS)
    --black:setFillColor(0, 255, 255, 255)
    white:setFillColor(255, 255, 255, 255)

    timer.performWithDelay(100, function()
        local name = self:maskFileName()
        display.save(white, name, system.TemporaryDirectory)
        timer.performWithDelay(100, function()
            --black:removeSelf()
            white:removeSelf()
            group:removeSelf()
            group = nil
            finish(name)
        end)
    end)
end

function CBRoundRectImageView:maskFileName()
    local margin = 3
    local width = math.ceil((self.image.contentWidth + margin * 2) / 4.0) * 4
    local height = math.ceil((self.image.contentHeight + margin * 2) / 4.0) * 4
    return "__chartboost_roundrect_"..tostring(width).."x"..tostring(width)..".jpg"
end
         --]]

return CBRoundRectImageView