--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This file holds a few different animation types
-- Examine the code to learn how to instantiate the different options
-- These classes are used in CBAnimationManager
--

local class = require "chartboost.libraries.lib.class"

local AlphaAnimation = class(function(self, fromA, toA)
    assert(type(fromA) == "number", "First parameter 'fromA' must be a number.")
    assert(type(toA) == "number", "Second parameter 'toA' must be a number.")
    self.alpha = {from = fromA, to = toA}
end)

local ScaleAnimation = class(function(self, fromX, toX, fromY, toY)
    assert(type(fromX) == "number", "First parameter 'fromX' must be a number.")
    assert(type(toX) == "number", "Second parameter 'toX' must be a number.")
    assert(type(fromY) == "number", "Third parameter 'fromY' must be a number.")
    assert(type(toY) == "number", "Fourth parameter 'toY' must be a number.")
    self.xScale = {from = fromX, to = toX}
    self.yScale = {from = fromY, to = toY}
end)

local TranslateAnimation = class(function(self, fromX, toX, fromY, toY)
    assert(type(fromX) == "number", "First parameter 'fromX' must be a number.")
    assert(type(toX) == "number", "Second parameter 'toX' must be a number.")
    assert(type(fromY) == "number", "Third parameter 'fromY' must be a number.")
    assert(type(toY) == "number", "Fourth parameter 'toY' must be a number.")
    self.x = {from = fromX, to = toX}
    self.y = {from = fromY, to = toY}
end)

local CBFlipAnimation = class(function(self, from_degrees, to_degrees, x_center, y_center, yaxis)
    assert(type(from_degrees) == "number", "First parameter 'from_degrees' must be a number.")
    assert(type(to_degrees) == "number", "Second parameter 'to_degrees' must be a number.")
    assert(type(x_center) == "number", "Third parameter 'x_center' must be a number.")
    assert(type(y_center) == "number", "Fourth parameter 'y_center' must be a number.")
    assert(type(yaxis) == "number", "Fifth parameter 'yaxis' must be a number.")
    self.fromDegrees = from_degrees
    self.toDegrees = to_degrees
    self.centerX = x_center
    self.centerY = y_center
    self.yAxis = yaxis
end)

--[[ caveat: corona does not yet support perspective skewing
--  update: I think it is supported now, let's figure this out sometime
--  example code from android follows:
function CBFlipAnimation:applyTransformation(interpolatedTime, t)
    local degrees = self.fromDegrees + ((self.toDegrees - self.fromDegrees) * interpolatedTime)
    local camera = self.camera
    local matrix = t.getMatrix()
    camera.save()

    if self.yAxis then
        camera.rotateY(degrees)
    else
        camera.rotateX(degrees)
    end

    camera.getMatrix(matrix)
    camera.restore()
    matrix.preTranslate(-self.centerX, -self.centerY)
    matrix.postTranslate(self.centerX, self.centerY)
end    --]]

return {AlphaAnimation = AlphaAnimation,
        ScaleAnimation = ScaleAnimation,
        TranslateAnimation = TranslateAnimation,
        CBFlipAnimation = CBFlipAnimation}