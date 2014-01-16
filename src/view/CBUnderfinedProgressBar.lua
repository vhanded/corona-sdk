--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class draws a progress bar.
-- Instantiate using CBUnderfinedProgressBar(x, y, width, height)
--   Field 'progressBar.group' must be added to the stage to see this view
--   Call method 'progressBar:destroy()' to remove the view from the stage and perform cleanup
--

local kCBProgressBarOutlineWidth = 3.0
local kCBProgressBarRefreshInterval = 1.0/60* 1000
local kCBProgressBarRefreshStep = 1.0

local class = require "chartboost.libraries.lib.class"
local CBUtility = require "chartboost.libraries.CBUtility"

local CBUnderfinedProgressBar = class(function(self, x, y, width, height)
    assert(type(x) == "number", "First parameter 'x' must be a number.")
    assert(type(y) == "number", "Second parameter 'y' must be a number.")
    assert(type(width) == "number", "Third parameter 'width' must be a number.")
    assert(type(height) == "number", "Fourth parameter 'height' must be a number.")
    local density = CBUtility.dpToPixels(1)
    self.offset = 0.0
    self.lastFrame = 0
    self.width, self.height = width, height

    self.group = display.newGroup()

    local inset = kCBProgressBarOutlineWidth / 2 * density
    self.inset = inset
    local elementSize, elementLength
    elementSize = self.height - kCBProgressBarOutlineWidth * 3 * density
    elementLength = self.width - kCBProgressBarOutlineWidth * 3 * density
    self.cornerRadius = self.height / 2.0

    self.capsule = display.newRoundedRect(inset, inset, self.width - 2 * inset, self.height - 2 * inset, self.cornerRadius)
    self.capsule.strokeWidth = kCBProgressBarOutlineWidth * density
    self.capsule:setStrokeColor(255/255, 255/255, 255/255)
    self.capsule:setFillColor(0, 0, 0, 0)

    self.shapes = {}

    self.onStep = function(event)
        local elapsed = 1
        if self.lastFrame > 0 then
            elapsed = (event.time - self.lastFrame) / kCBProgressBarRefreshInterval
            self.lastFrame = event.time
        end

        local density = CBUtility.dpToPixels(1)
        self.offset = self.offset + kCBProgressBarRefreshStep * density * elapsed

        local elementSize
        elementSize = self.height
        elementSize = elementSize - 3 * kCBProgressBarOutlineWidth * density

        if (self.offset > elementSize) then
            self.offset = self.offset - 2 * elementSize
        end

        -- For each element path
        local left = -elementSize + self.offset
        local index = 1
        while left < (elementLength + elementSize) do
            local elementOriginX = kCBProgressBarOutlineWidth * 3 / 2 * density + left
            local shape = self:getShape(index)
            shape.isVisible = true

            -- Shift context
            shape.x, shape.y = elementOriginX - inset, 0
            shape.setLimits()

            left = left + 2 * elementSize
            index = index + 1
        end
        if index <= #self.shapes then
            for i = index, #self.shapes do
                self.shapes[i].isVisible = false
            end
        end
    end
    Runtime:addEventListener("enterFrame", self.onStep)

    self.onStep({time = 0})

    self.group:insert(self.capsule)

    self.group.x = x
    self.group.y = y
end)

function CBUnderfinedProgressBar:destroy()
    Runtime:removeEventListener("enterFrame", self.onStep)
    if (self.capsule) then
        self.capsule:removeSelf()
        self.capsule = nil
    end
    if self.shapes then
        for k,v in pairs(self.shapes) do
            v:removeSelf()
        end
        self.shapes = nil
    end
    if (self.group) then
        self.group:removeSelf()
        self.group = nil
    end
end

function CBUnderfinedProgressBar:getShape(i)
    assert(type(i) == "number", "First parameter 'i' must be a number.")
    if not self.shapes then
        self.shapes = {}
    end
    for index = 1,i do
        if not self.shapes[index] then
            self.shapes[index] = self:createShape()
        end
    end
    return self.shapes[i]
end

function CBUnderfinedProgressBar:createShape()
    local density = CBUtility.dpToPixels(1)
    -- Work out the inner trapezoids shape
    local elementSize, elementShape, coords
    elementSize = self.height - kCBProgressBarOutlineWidth * 2 / 2 * density
    coords = {{x = 0, y = elementSize}, {x = elementSize, y = elementSize},
        {x = elementSize * 2, y = 0}, {x = elementSize, y = 0}, {x = 0, y = elementSize}}

    local elementShape = self:paintPoly(coords, 0, 0, {255, 255, 255, 255})
    -- elementShape:setReferencePoint(display.TopLeftReferencePoint)
    elementShape.anchorX = 0; elementShape.anchorY = 0;
    self.group:insert(elementShape)
    return elementShape
end

function CBUnderfinedProgressBar:paintPoly(poly, xoffset, yoffset, rgba)
    assert(type(poly) == "table", "First parameter 'poly' must be an array of coordinate tables {x = x, y = y}.")
    assert(type(xoffset) == "number", "Second parameter 'xoffset' must be a number.")
    assert(type(yoffset) == "number", "Third parameter 'yoffset' must be a number.")
    assert(type(rgba) == "table", "Fourth parameter 'rgba' must be a color table.")
    local math_floor = math.floor
    local math_min = math.min
    local math_max = math.max
    local math_asin = math.asin
    local math_cos = math.cos
    local newLine = function(x1, y1, x2, y2)
        x1, x2 = math_min(x1, x2), math_max(x1, x2)
        local l = display.newLine(x1, y1, x2, y2)
        l.x1, l.y1, l.x2, l.y2 = x1, y1, x2, y2
        l.xI, l.yI = l.x, l.y
        l.setLimits = function()
            local poly = l.parent
            local lx1 = l.xI + poly.x + self.inset
            local ly1 = l.yI + poly.y + self.inset
            local lx2 = lx1 + (l.x2 - l.x1)
            local ly2 = ly1 + (l.y2 - l.y1)

            local density = CBUtility.dpToPixels(1)
            local inset = kCBProgressBarOutlineWidth / 2 * density

            local yC = self.height / 2.0
            local xLC = inset + self.cornerRadius
            local xRC = self.width - 1.5 * inset - self.cornerRadius

            -- equation:
            --   x, y = r cos a, r sin a
            --   r sin a == l.y
            --   sin a == l.y / cornerRadius
            local sinA = (ly1 + 0.5 - yC) / self.cornerRadius
            if (sinA < -1 or sinA > 1) then
                l.isVisible = false -- too high or low
                return
            else
                l.isVisible = true
            end
            local angle = math_asin(sinA)
            local cosA = math_cos(angle)
            local xL = xLC - self.cornerRadius * cosA
            local xR = xRC + self.cornerRadius * cosA

            if lx2 <= xL or lx1 >= xR then
                l.isVisible = false
            elseif lx1 < xL then
                l.xScale = (lx2 - xL) / (l.x2 - l.x1)
                l.x = xL - poly.x - self.inset
            elseif lx2 > xR then
                l.xScale = (xR - lx1) / (l.x2 - l.x1)
                l.x = lx1 - poly.x - self.inset
            elseif lx1 >= xL and lx2 <= xR then
                l.x = l.xI
                l.xScale = 1
            else
                l.isVisible = false
            end
        end
        return l
    end
    local polyGroup = display.newGroup()

    local n = #poly

    local minY = poly[1].y
    local maxY = poly[1].y

    for i = 2, n do
        minY = math_min(minY, poly[i].y)
        maxY = math_max(maxY, poly[i].y)
    end

    for y = minY, maxY do
        local ints = {}
        local int = 0
        local last = n

        for i = 1, n do
            local y1 = poly[last].y
            local y2 = poly[i].y
            if y1 < y2 then
                local x1 = poly[last].x
                local x2 = poly[i].x
                if (y >= y1) and (y < y2) then
                    int = int + 1
                    ints[int] = math_floor((y - y1) * (x2 - x1) / (y2 - y1) + x1)
                end
            elseif y1 > y2 then
                local x1 = poly[last].x
                local x2 = poly[i].x
                if (y >= y2) and (y < y1) then
                    int = int + 1
                    ints[int] = math_floor((y - y2) * (x1 - x2) / (y1 - y2) + x2)
                end
            end
            last = i
        end

        local i = 1
        while i < int do
            local line = newLine(ints[i] + xoffset, y + yoffset, ints[i + 1] + xoffset, y + yoffset)
            polyGroup:insert(line)
            -- line:setReferencePoint(display.TopLeftReferencePoint)
            line.anchorX = 0; line.anchorY = 0;
            line:setColor(rgba[1]/255, rgba[2]/255, rgba[3]/255, rgba[4]/255)
            i = i + 2
        end
    end

    polyGroup.setLimits = function()
        if not polyGroup.numChildren then
            return
        end
        for i=1,polyGroup.numChildren do
            polyGroup[i].setLimits()
        end
    end

    return polyGroup
end

return CBUnderfinedProgressBar