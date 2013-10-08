--
-- Chartboost Corona SDK
-- Created by: Chris
--

local class = require "chartboost.libraries.lib.class"
local CBImpressionState = require "chartboost.model.CBImpressionState"
local CBImpressionType = require "chartboost.model.CBImpressionType"
local CBAnimationType = require "chartboost.model.CBAnimationType"
local CBOrientation = require "chartboost.model.CBOrientation"
local CBLoadingView = require "chartboost.view.CBLoadingView"
local CBPopupImpressionView = require "chartboost.view.CBPopupImpressionView"
local CBAnimationManager = require "chartboost.view.CBAnimationManager"
	
local CBViewController = class(function(self, cbProxy)
    assert(type(cbProxy) == "table", "First parameter 'cbProxy' must be a CBProxy.")
    self.cbProxy = cbProxy
    self.loadingViewIsVisible = false
    self.viewIsVisible = false
    self.waitingForImpressionToDismiss = false
    self.orientation = CBOrientation.mapOrientation(system.orientation)

    self.onOrientationChange = function(event)
        self.orientation = CBOrientation.mapOrientation(event.type)
    end
    Runtime:addEventListener("orientation", self.onOrientationChange)
end)

function CBViewController:isAnyViewVisible()
    return self.loadingViewIsVisible or self.viewIsVisible
end

function CBViewController:destroy()
    Runtime:removeEventListener("orientation", self.onOrientationChange)
end

function CBViewController:displayImpressionView(impression)
    assert(type(impression) == "table", "First parameter 'impression' must be a CBImpression.")
    -- Never show two ads at once
    if self.viewIsVisible then
        return
    end

    impression.state = CBImpressionState.CBImpressionStateWaitingForDisplay

    local success, error = impression.view.viewProtocol:createView()
    if not success then -- in case chartboost view was unable to be set up
        if impression.view.viewProtocol.failCallback then
            impression.view.viewProtocol.failCallback(error)
        end
        return
    end
    
    if impression.overrideAnimation then
        impression.overrideAnimation = false
        self.impressionPopup = CBPopupImpressionView(self.cbProxy, impression.view.view)
        self.impressionPopup:addToStage()

        impression.state = CBImpressionState.CBImpressionStateDisplayedByDefaultController
        impression.parentView = self.impressionPopup
        self.viewIsVisible = true
    else
        -- Fade in the background chartboost view
        self.impressionPopup = CBPopupImpressionView(self.cbProxy, impression.view.view)
        self.impressionPopup.backgroundView:fadeIn()
        
        -- Pop in the CBView
        local animation = CBAnimationType.CBAnimationTypePerspectiveRotate -- default interstitial anim
        if impression.type == CBImpressionType.CBImpressionTypeMoreApps then
            animation = CBAnimationType.CBAnimationTypePerspectiveZoom -- default more apps anim
        end
        local customAnim = tonumber(impression.responseContext["animation"])
        if customAnim and customAnim > 0 then
            animation = CBAnimationType.getByIndex(customAnim) or animation
        end

        impression.state = CBImpressionState.CBImpressionStateDisplayedByDefaultController
        impression.parentView = self.impressionPopup
        CBAnimationManager.transitionInWithAnimationType(animation, impression)
        self.viewIsVisible = true
        
        local delegate = self.cbProxy.getDelegate()
        if delegate then
            if impression.type == CBImpressionType.CBImpressionTypeInterstitial then
                if delegate.didShowInterstitial then
                    delegate.didShowInterstitial(impression.location)
                end
            elseif impression.type == CBImpressionType.CBImpressionTypeMoreApps then
                if delegate.didShowMoreApps then
                    delegate.didShowMoreApps()
                end
            end
        end
    end
end

--- Dismiss the loading chartboost view.
---  impression : the impression to dismiss
---  lastView : true if there is not a chartboost view that will be shown after self one.
function CBViewController:dismissImpression(impression, lastView)
    assert(type(impression) == "table", "First parameter 'impression' must be a CBImpression.")
    assert(type(lastView) == "boolean", "Second parameter 'lastView' must be a boolean.")
    self.viewIsVisible = false
    
    if not lastView then
        self.waitingForImpressionToDismiss = true
    end
    
    impression.state = CBImpressionState.CBImpressionStateWaitingForDismissal
    
    local animation = CBAnimationType.CBAnimationTypePerspectiveRotate --default interstitial anim
    if impression.type == CBImpressionType.CBImpressionTypeMoreApps then
        animation = CBAnimationType.CBAnimationTypePerspectiveZoom --default more apps anim
    end
    local customAnim = tonumber(impression.responseContext["animation"])
    if customAnim and customAnim > 0 then
        animation = CBAnimationType.getByIndex(customAnim) or animation
    end

    local block = function(impression)
        -- delay execution of self
        -- because you cannot modify the chartboost view hierarchy in onAnimationEnd
        if impression.state == CBImpressionState.CBImpressionStateWaitingForDismissal then
            impression.state = CBImpressionState.CBImpressionStateOther
            self:removeImpression(impression, false)
        end
    end
    CBAnimationManager.transitionOutWithAnimationType(animation, impression, block)
end

--- call self to hide an impression without any animation or marking that impression object as dismissed
function CBViewController:dismissImpressionSilently(impression)
    self.viewIsVisible = false
    
    if impression.state == CBImpressionState.CBImpressionStateWaitingForDismissal then
        impression.state = CBImpressionState.CBImpressionStateOther
        self:removeImpression(impression, true)
    end
    if impression.state == CBImpressionState.CBImpressionStateDisplayedByDefaultController then
        impression.state = CBImpressionState.CBImpressionStateWaitingForDisplay
    else
        impression.state = CBImpressionState.CBImpressionStateOther
    end
    
    impression:cleanUpViews()

    self.impressionPopup:removeFromStage()
    self.impressionPopup = nil
end

function CBViewController:displayLoadingView()
    self.loadingView = CBLoadingView(self.cbProxy)
    
    -- Show views
    -- Fade in the background chartboost view
    self.loadingViewPopup = CBPopupImpressionView(self.cbProxy, self.loadingView)
    self.loadingViewPopup.backgroundView:setGradientReversed(true)
    self.loadingViewPopup:addToStage()
    self.loadingViewPopup.backgroundView:fadeIn()
    self.loadingViewPopup.backgroundView:fadeIn(self.loadingViewPopup.group)

    self.loadingViewIsVisible = true
end

--- Dismiss the loading chartboost view.
---  lastView : true if there is not a chartboost view that will be shown after self one.
function CBViewController:dismissLoadingView()
    if self.loadingViewIsVisible then
        self.loadingView:destroy()
        self.loadingViewPopup:removeFromStage()
        self.loadingView = nil
        self.loadingViewPopup = nil
        self.loadingViewIsVisible = false
    end
end

function CBViewController:removeImpression(impression, silent)
    assert(type(impression) == "table", "First parameter 'impression' must be a CBImpression.")
    assert(type(silent) == "boolean", "Second parameter 'silent' must be a boolean.")
    if not self.impressionPopup then
        return
    end
    impression:destroy()
    self.impressionPopup = nil
    self.waitingForImpressionToDismiss = false
end

return CBViewController