--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- Enumeration of animation types
--

local anim = {
    CBAnimationTypeNone = "CBAnimationTypeNone",
    CBAnimationTypePerspectiveRotate = "CBAnimationTypePerspectiveRotate",
    CBAnimationTypeBounce = "CBAnimationTypeBounce",
    CBAnimationTypePerspectiveZoom = "CBAnimationTypePerspectiveZoom",
    CBAnimationTypeSlideFromBottom = "CBAnimationTypeSlideFromBottom",
    CBAnimationTypeSlideFromTop = "CBAnimationTypeSlideFromTop"
}

local function getByIndex(index)
    if index == 1 then
        return anim.CBAnimationTypePerspectiveRotate
    elseif index == 2 then
        return anim.CBAnimationTypeBounce
    elseif index == 3 then
        return anim.CBAnimationTypePerspectiveZoom
    elseif index == 4 then
        return anim.CBAnimationTypeSlideFromBottom
    elseif index == 5 then
        return anim.CBAnimationTypeSlideFromTop
    elseif index == 6 then
        return anim.CBAnimationTypeNone
    else
        return nil
    end
end

anim.getByIndex = getByIndex

anim.assert = function(imp)
    for k,v in pairs(anim) do
        if v == imp then
            return true
        end
    end
    return false
end

return anim