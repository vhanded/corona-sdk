--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This enum is used by internal Chartboost code!
-- Do not modify its public interface!
--
-- This class returns two enumerations - orientations and differences.
--
-- The orientations table is an enum that represents all of the possible screen orientations.
-- It is used to override the orientation at which impressions might be displayed.
-- While you see 8 different choices here (in addition to UNSPECIFIED), there are
--  only 4 actual different orientations. The other 4 are aliases to increase the
--  descriptive power of your code. Read the documentation for each orientation
--  to learn more.
--

local ret = {}

local function CBOrientation(name, printName, angle)
    local t = {type = "CBOrientation", name = name, printName = printName, angle = angle }
    local mt = {
        __eq = function(a, b)
            if not a and not b then
                return true
            end
            if not a or not b then
                return false
            end
            if not ret.assertOrient(a) and not ret.assertOrient(b) then
                return rawequal(a, b)
            end
            if not ret.assertOrient(a) or not ret.assertOrient(b) then
                return false
            end
            return (a.type == b.type and a.name == b.name and a.angle == b.angle)
        end
    }
    setmetatable(t, mt)
    return t
end

local orientations = {
    -- no specific orientation
    UNSPECIFIED = CBOrientation("UNSPECIFIED", "Unspecified", nil),
    -- default portrait orientation on a portrait device
    PORTRAIT = CBOrientation("PORTRAIT", "Portrait", 0),
    -- default landscape orientation on a landscape device
    LANDSCAPE = CBOrientation("LANDSCAPE", "Landscape", 90),
    -- reverse portrait orientation on a portrait device
    PORTRAIT_REVERSE = CBOrientation("PORTRAIT_REVERSE", "Reverse Portrait", 180),
    -- reverse landscape orientation on a landscape device
    LANDSCAPE_REVERSE = CBOrientation("LANDSCAPE_REVERSE", "Reverse Landscape", 270)
}

local function getOrientationByAngle(angle)
    for k,o in pairs(orientations) do
        if o.angle == angle then
            return o
        end
    end
    return nil
end

-- add helper methods to orientation objects
for k,o in pairs(orientations) do
    o.isPortrait = function()
        return o.angle == 0 or o.angle == 180
    end
    o.isLandscape = function()
        return o.angle == 90 or o.angle == 270
    end

    -- this orientation if the device were rotated 270 degrees clockwise,
    -- or the screen rotated 90 degrees clockwise
    o.rotate90 = function()
        local angle = o.angle + 90
        angle = angle - math.floor(angle / 360) * 360 --modulus
        return getOrientationByAngle(angle)
    end
    o.rotate180 = function()
        return o.rotate90().rotate90()
    end
    o.rotate270 = function()
        return o.rotate90().rotate90().rotate90()
    end
end

-- add aliases
-- left portrait orientation on a landscape device (alias for PORTRAIT_REVERSE)
orientations.PORTRAIT_LEFT = orientations.PORTRAIT_REVERSE
-- right portrait orientation on a landscape device (alias for PORTRAIT)
orientations.PORTRAIT_RIGHT = orientations.PORTRAIT
-- left landscape orientation on a portrait device (alias for LANDSCAPE)
orientations.LANDSCAPE_LEFT = orientations.LANDSCAPE
-- right landscape orientation on a portrait device (alias for LANDSCAPE_REVERSE)
orientations.LANDSCAPE_RIGHT = orientations.LANDSCAPE_REVERSE


-- an enum used to represent the angular difference
-- between two different orientations */
local function CBOrientationDifference(name, diff)
    return {type = "CBOrientationDifference", name = name, diff = diff}
end

local differences = {
    -- default portrait orientation on a portrait device
    ANGLE_0 = CBOrientationDifference("ANGLE_0", 0),
    -- default landscape orientation on a landscape device
    ANGLE_90 = CBOrientationDifference("ANGLE_90", 90),
    -- reverse portrait orientation on a portrait device
    ANGLE_180 = CBOrientationDifference("ANGLE_180", 180),
    -- reverse landscape orientation on a landscape device
    ANGLE_270 = CBOrientationDifference("ANGLE_270", 270),
}

-- add helper methods to orientation difference objects
for k,o in pairs(differences) do
    o.isOdd = function()
        return o.diff == 90 or o.diff == 270
    end
    o.isReverse = function()
        return o.diff == 180 or o.diff == 270
    end
    o.flipIfOdd = function(x, y)
        if o.isOdd() then
            return y, x
        else
            return x, y
        end
    end
end

ret.orientations = orientations
ret.differences = differences

ret.mapOrientation = function(name)
    if name == "landscapeRight" then
        return orientations.LANDSCAPE_LEFT
    elseif name == "portraitUpsideDown" then
        return orientations.PORTRAIT_REVERSE
    elseif name == "landscapeLeft" then
        return orientations.LANDSCAPE_RIGHT
    else --if name == "portrait" or name == "faceUp" or name == "faceDown" then
        return orientations.PORTRAIT
    end
end

ret.assertOrient = function(imp)
    for k,v in pairs(ret.orientations) do
        if v.type == imp.type and v.name == imp.name and v.angle == imp.angle then
            return true
        end
    end
    return false
end

ret.assertDiff = function(imp)
    for k,v in pairs(ret.differences) do
        if v == imp then
            return true
        end
    end
    return false
end

return ret