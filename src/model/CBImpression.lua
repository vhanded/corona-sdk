--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class is used by internal Chartboost code!
-- Do not modify its public interface!
--
-- This class represents an impression and manages its own life cycle
-- Instantiate using CBImpression(cbProxy, response, CBImpressionType, CBImpressionProtocol,
--                                CBImpressionState, initialLocation, loadingViewShown)
--   Use impression:prepareAssets() to begin the asset downloading and view showing process.
--   Call method 'impression:destroy()' to remove the view from the stage and perform cleanup
--

local class = require "chartboost.libraries.lib.class"
local CBImpressionType = require "chartboost.model.CBImpressionType"
local CBImpressionState = require "chartboost.model.CBImpressionState"
local CBUtility = require "chartboost.libraries.CBUtility"
local CBNativeInterstitialViewProtocol = require "chartboost.nativeviews.CBNativeInterstitialViewProtocol"
local CBMoreAppsViewProtocol = require "chartboost.nativeviews.CBMoreAppsViewProtocol"
local CBWebViewProtocol = require "chartboost.view.CBWebViewProtocol"

-- params: self, table (json), CBImpressionType, CBImpressionProtocol, CBImpressionState, string
local CBImpression = class(function(self, cbProxy, response, impressionType, impressionDelegate,
                                        initialState, initialLocation, loadingViewShown)
    self.cbProxy = cbProxy
    if not response then
        response = {}
    end
    assert(type(cbProxy) == "table", "First parameter 'cbProxy' must be a CBProxy.")
    assert(type(response) == "table", "Second parameter 'response' must be a table.")
    assert(CBImpressionType.assert(impressionType), "Third parameter 'impressionType' must be a CBImpressionType.")
    assert(type(impressionDelegate) == "table", "Fourth parameter 'impressionDelegate' must be a table of functions.")
    assert(CBImpressionState.assert(initialState), "Fifth parameter 'title' must be a CBImpressionState.")
    if initialLocation then assert(type(initialLocation) == "string", "Sixth parameter 'initialLocation' must be a string.") end
    assert(type(loadingViewShown) == "boolean", "Seventh parameter 'loadingViewShown' must be a boolean.")
    self.state = initialState
    self.location = initialLocation
    self.responseContext = response
    self.responseDate = os.time()
    self.delegate = impressionDelegate
    self.type = impressionType
    self.loadingViewShown = loadingViewShown
    self.overrideAnimation = false
    self.overrideLoadingViewRequirement = false
    self.overrideAskToShow = false
    local useNative = response["type"] == "native"

    if useNative and self.type == CBImpressionType.CBImpressionTypeInterstitial then
        self.view = CBNativeInterstitialViewProtocol(self)
    elseif useNative and self.type == CBImpressionType.CBImpressionTypeMoreApps then
        self.view = CBMoreAppsViewProtocol(self)
    else
        self.view = CBWebViewProtocol(self)
    end

    self.view.viewProtocol.displayCallback = function()
        if self.delegate then
            self.delegate:impressionReadyToBeDisplayed(self)
        end
    end

    self.view.viewProtocol.closeCallback = function()
        if self.delegate then
            self.delegate:impressionCloseTriggered(self)
        end
    end

    self.view.viewProtocol.clickCallback = function(url, moreData)
        url = url or self.responseContext["link"]
        local deepLink = self.responseContext["deep-link"]
        if deepLink and deepLink ~= "" then
            local scheme = CBUtility.getUrlScheme(deepLink) .. "://"
            local isAppInstalled = system.openURL(scheme) --"skype://")
            if isAppInstalled then -- at least one application can open self URL
                url = deepLink
            end
        end
        if self.delegate then
            self.delegate:impressionClickTriggered(self, url, moreData)
        end
    end

    self.view.viewProtocol.failCallback = function(error)
        if self.delegate then
            self.delegate:impressionFailedToInitialize(self, error)
        end
    end
end)

function CBImpression:prepareAssets()
    self.view:prepareWithResponse(self.responseContext)
end


--- call this to attempt to recreate the chartboost.view of a previously shown impression.
--- Returns true if successful. If the assets are still loading, it will return false,
--- and the chartboost.view will still be created once the assets finish loading.
function CBImpression:reinitialize()
    self.overrideAnimation = true
    self.overrideLoadingViewRequirement = true
    self.overrideAskToShow = true
    self.view:setReadyToDisplay()
    if self.view:getView() then
        return true
    end

    -- the chartboost.view was not created yet, so self is actually a normal load - remove the overrides
    self.overrideAnimation = false
    self.overrideLoadingViewRequirement = false
    self.overrideAskToShow = false
    return false
end

function CBImpression:destroy()
    if self.view then
        self.view:destroy() -- calls through to destroyView
    end
    if self.parentView then
        self.parentView:destroy()
    end
    self.delegate = nil
    self.view = nil
    self.parentView = nil
end

function CBImpression:cleanUpViews()
    if self.parentView then
        self.parentView:destroy()
    end
    if self.view then
        self.view:destroyView()
    end
end

return CBImpression