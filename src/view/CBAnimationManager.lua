--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This file contains methods used to animate content
--

local CBAnimationType = require "chartboost.model.CBAnimationType"
local CBAnimations = require "chartboost.view.CBAnimations"

--- params: CBAnimationType, CBImpression, CBAnimationProtocol, boolean
local function doTransitionWithAnimationType(animType, impression, block, isInTransition)
    assert(CBAnimationType.assert(animType), "First parameter 'animType' must be a CBAnimationType.")
    assert(type(impression) == "table", "Second parameter 'impression' must be a CBImpression.")
    if block then assert(type(block) == "function", "Third parameter 'block' must be a function or nil.") end
    assert(type(isInTransition) == "boolean", "Fourth parameter 'isInTransition' must be a boolean.")
    local animDuration = 600

    -- do checks to see if impression has been canceled prior to self animation getting a chance to occur
    if not impression or not impression.parentView then
        return
    end
    local layer = impression.parentView.content
    if not layer then
        return
    end
    layer = layer.group

    local width = display.contentWidth
    local height = display.contentHeight
    local degrees = 60
    local scale = 0.4
    local offset = (1.0 - scale) / 2.0

    local rotateAnimation
    local scaleAnimation
    local translateAnimation

    local listener = function()
        if block then
            block(impression)
        end
    end

    if animType == CBAnimationType.CBAnimationTypeNone then
        listener()
        return
    end

    local addParams = function(params, anim)
        if anim then
            for k,v in pairs(anim) do
                if type(v) == "table" and v.from and v.to then
                    params[k] = v.to
                    layer[k] = v.from
                end
            end
        end
    end

    if animType == CBAnimationType.CBAnimationTypePerspectiveZoom then
        if (isInTransition) then
            rotateAnimation = CBAnimations.AlphaAnimation(0, 1.0)
            scaleAnimation = CBAnimations.ScaleAnimation(scale, 1.0, scale, 1.0)
            translateAnimation = CBAnimations.TranslateAnimation(width * offset, 0, -height * scale, 0)
        else
            rotateAnimation = CBAnimations.AlphaAnimation(1.0, 0)
            scaleAnimation = CBAnimations.ScaleAnimation(1.0, scale, 1.0, scale)
            translateAnimation = CBAnimations.TranslateAnimation(0, width * offset, 0, height)
        end

        local animParams = {time = animDuration, onComplete = listener}
        addParams(animParams, rotateAnimation)
        addParams(animParams, scaleAnimation)
        addParams(animParams, translateAnimation)
        transition.to(layer, animParams)
    elseif animType == CBAnimationType.CBAnimationTypePerspectiveRotate then
        if (isInTransition) then
            rotateAnimation = CBAnimations.AlphaAnimation(0, 1.0)
            scaleAnimation = CBAnimations.ScaleAnimation(scale, 1.0, scale, 1.0)
            translateAnimation = CBAnimations.TranslateAnimation(-width * scale, 0, height * offset, 0)
        else
            rotateAnimation = CBAnimations.AlphaAnimation(1.0, 0)
            scaleAnimation = CBAnimations.ScaleAnimation(1.0, scale, 1.0, scale)
            translateAnimation = CBAnimations.TranslateAnimation(0, width, 0, height * offset)
        end
        local animParams = {time = animDuration, onComplete = listener}
        addParams(animParams, rotateAnimation)
        addParams(animParams, scaleAnimation)
        addParams(animParams, translateAnimation)
        --print((require "json").encode(animParams))
        transition.to(layer, animParams)
    elseif animType == CBAnimationType.CBAnimationTypeSlideFromBottom then
        local fromx, tox = 0, 0
        local fromy, toy = 0, 0
        if (isInTransition) then
            fromy = height
        else
            toy = height
        end
        translateAnimation = CBAnimations.TranslateAnimation(fromx, tox, fromy, toy)

        local animParams = {time = animDuration, onComplete = listener}
        addParams(animParams, translateAnimation)
        transition.to(layer, animParams)
    elseif animType == CBAnimationType.CBAnimationTypeSlideFromTop then
        local fromx, tox = 0, 0
        local fromy, toy = 0, 0
        if (isInTransition) then
            fromy = -height
        else
            toy = -height
        end
        translateAnimation = CBAnimations.TranslateAnimation(fromx, tox, fromy, toy)

        local animParams = {time = animDuration, onComplete = listener}
        addParams(animParams, translateAnimation)
        transition.to(layer, animParams)
    elseif animType == CBAnimationType.CBAnimationTypeBounce then
        -- layer:setReferencePoint(display.CenterReferencePoint)
        layer.anchorX = 0.5; layer.anchorY = 0.5
        if (isInTransition) then
            scaleAnimation = CBAnimations.ScaleAnimation(0.6, 1.1, 0.6, 1.1)
            local animParams = {time = animDuration * 0.6, onComplete = function()
                local scaleAnimation2 = CBAnimations.ScaleAnimation(1.1, 0.9, 1.1, 0.9)
                local animParams2 = {time = animDuration * (0.8 - 0.6), onComplete = function()
                    local scaleAnimation3 = CBAnimations.ScaleAnimation(0.9, 1, 0.9, 1)
                    local animParams3 = {time = animDuration * (0.9 - 0.8), onComplete = function()
                        -- layer:setReferencePoint(display.TopLeftReferencePoint)
                        layer.anchorX = 0; layer.anchorY = 0;
                        listener()
                    end}
                    addParams(animParams3, scaleAnimation3)
                    transition.to(layer, animParams3)
                end}
                addParams(animParams2, scaleAnimation2)
                transition.to(layer, animParams2)
            end}
            addParams(animParams, scaleAnimation)
            transition.to(layer, animParams)
        else
            scaleAnimation = CBAnimations.ScaleAnimation(1.0, 0, 1.0, 0)
            local animParams = {time = animDuration, onComplete = listener}
            addParams(animParams, scaleAnimation)
            transition.to(layer, animParams)
        end
    end
end

--- params: CBAnimationType, CBImpression, CBAnimationProtocol, boolean
--- Make sure chartboost view gets measured before we start animation
local function transitionWithAnimationType(animType, impression, block, isInTransition)
    assert(CBAnimationType.assert(animType), "First parameter 'animType' must be a CBAnimationType.")
    assert(type(impression) == "table", "Second parameter 'impression' must be a CBImpression.")
    if block then assert(type(block) == "function", "Third parameter 'block' must be a function or nil.") end
    assert(type(isInTransition) == "boolean", "Fourth parameter 'isInTransition' must be a boolean.")
    -- do checks to see if impression has been canceled prior to this animation getting a chance to occur
    if not impression or not impression.parentView then
        return
    end
    local layer = impression.parentView.content
    if not layer then
        return
    end
    doTransitionWithAnimationType(animType, impression, block, isInTransition)
end

--- params: CBAnimationType, CBImpression, CBAnimationProtocol
local function transitionInWithAnimationType(animType, impression, block)
    assert(CBAnimationType.assert(animType), "First parameter 'animType' must be a CBAnimationType.")
    assert(type(impression) == "table", "Second parameter 'impression' must be a CBImpression.")
    if block then assert(type(block) == "function", "Third parameter 'block' must be a function or nil.") end
    transitionWithAnimationType(animType, impression, block, true)
end

--- params: CBAnimationType, CBImpression, CBAnimationProtocol
local function transitionOutWithAnimationType(animType, impression, block)
    assert(CBAnimationType.assert(animType), "First parameter 'animType' must be a CBAnimationType.")
    assert(type(impression) == "table", "Second parameter 'impression' must be a CBImpression.")
    if block then assert(type(block) == "function", "Third parameter 'block' must be a function or nil.") end
    doTransitionWithAnimationType(animType, impression, block, false)
end

return {
    transitionOutWithAnimationType = transitionOutWithAnimationType,
    transitionInWithAnimationType = transitionInWithAnimationType
}