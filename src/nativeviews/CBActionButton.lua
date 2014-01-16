--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used to create an orange button used in the more apps page.
-- Instantiate using CBActionButton(cbProxy, text, height, onClick)
--                     -- the final param is a method that acts as a click listener
--   Field 'view.group' must be added to the stage to see this view
--   Call method 'view:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBUtility = require "chartboost.libraries.CBUtility"

local FONT_SIZE = 16
local COLOR_TEXT = {255/255, 255/255, 255/255}
local COLOR_TEXT_SHADOW = {0x00/255, 0x4B/255, 0x73/255}

local CBActionButton = class(function(self, cbProxy, text, height, onClick)
    self.cbProxy = cbProxy
    self.text = text
    self.onClick = onClick
    self.height = height

    self.group = display.newGroup()

    local density = CBUtility.dpToPixels(1)

    local label = display.newText(self.text, 0, 0, native.systemFontBold, FONT_SIZE)
    label:setTextColor(unpack(COLOR_TEXT))
    self.label = label

    local labelS = display.newText(self.text, 1 * density, 1 * density, native.systemFontBold, FONT_SIZE)
    labelS:setTextColor(unpack(COLOR_TEXT_SHADOW))
    self.labelS = labelS

    self.group:insert(self.labelS)
    self.group:insert(self.label)
    labelS.anchorX = 0.5; labelS.anchorY = 0.5
    label.anchorX = 0.5; label.anchorY = 0.5
    --labelS:setReferencePoint(display.CenterReferencePoint)
    --label:setReferencePoint(display.CenterReferencePoint)

    self.width = math.max(48, label.width + 2 * 12 * density)

    self.imageOffL = self:loadImage("__chartboost_morebtn_off_l.png")
    self.imageOffM = self:loadImage("__chartboost_morebtn_off_m.png")
    self.imageOffR = self:loadImage("__chartboost_morebtn_off_r.png")
    self.imageOnL = self:loadImage("__chartboost_morebtn_on_l.png")
    self.imageOnM = self:loadImage("__chartboost_morebtn_on_m.png")
    self.imageOnR = self:loadImage("__chartboost_morebtn_on_r.png")

    self.imageOffL.x = 0
    self.imageOnL.x = 0
    self.imageOffM.xScale = (self.width - self.imageOffL.contentWidth - self.imageOffR.contentWidth) / self.imageOffM.width
    self.imageOnM.xScale = (self.width - self.imageOnL.contentWidth - self.imageOnR.contentWidth) / self.imageOnM.width
    self.imageOffM.x = self.imageOffL.contentWidth
    self.imageOnM.x = self.imageOnL.contentWidth
    self.imageOffR.x = self.imageOffL.contentWidth + self.imageOffM.contentWidth
    self.imageOnR.x = self.imageOnL.contentWidth + self.imageOnM.contentWidth

    self.imageOffL.yScale = self.height / self.imageOffL.height
    self.imageOnL.yScale = self.height / self.imageOnL.height
    self.imageOffM.yScale = self.height / self.imageOffM.height
    self.imageOnM.yScale = self.height / self.imageOnM.height
    self.imageOffR.yScale = self.height / self.imageOffR.height
    self.imageOnR.yScale = self.height / self.imageOnR.height

    self:setPressed(false)

    self.labelS:toFront()
    self.label:toFront()
    self.labelS.x = (self.imageOffL.contentWidth + self.imageOffM.contentWidth + self.imageOffR.contentWidth) / 2 + 2 * density
    self.label.x = (self.imageOffL.contentWidth + self.imageOffM.contentWidth + self.imageOffR.contentWidth) / 2
    self.labelS.y = (self.imageOffM.contentHeight) / 2 + 2 * density
    self.label.y = (self.imageOffM.contentHeight) / 2

    -- block clicks
    self.clickBlocker = display.newRect(self.group, 0, 0, self.group.contentWidth, self.group.contentHeight)
    self.clickBlocker.alpha = 0
    self.clickBlocker.isHitTestable = true -- Only needed if alpha is 0
    self.clickBlocker.x = display.contentCenterX; self.clickBlocker.y = display.contentCenterY;
    local inBtn = false
    self.clickBlocker:addEventListener("touch", function(event)
        if event.phase == "began" then
            inBtn = true
            display.getCurrentStage():setFocus(self.clickBlocker)
            self:setPressed(true)
        elseif event.phase == "moved" then
            local x, y = event.x, event.y
            local bounds = self.clickBlocker.contentBounds
            inBtn = (x >= bounds.xMin and x <= bounds.xMax and y >= bounds.yMin and y <= bounds.yMax)
            self:setPressed(inBtn)
        elseif event.phase == "ended" then
            if inBtn then
                self.onClick()
            end
            self:setPressed(false)
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end)
    self.group:insert(self.clickBlocker)
end)

function CBActionButton:setPressed(pressed)
    self.imageOnL.isVisible = pressed
    self.imageOnM.isVisible = pressed
    self.imageOnR.isVisible = pressed
    self.imageOffL.isVisible = not pressed
    self.imageOffM.isVisible = not pressed
    self.imageOffR.isVisible = not pressed
end

function CBActionButton:loadImage(name)
    local density = CBUtility.dpToPixels(1)
    local file = self.cbProxy.getPackagedImageFileName(name)
    local image = display.newImage(self.group, file, system.ResourceDirectory)
    image.yScale = self.height / image.height
    image.xScale = image.yScale
    image.anchorX = 0
    image.anchorY = 0
    --image:setReferencePoint(display.TopLeftReferencePoint)
    return image
end

return CBActionButton