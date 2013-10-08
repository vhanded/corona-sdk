--
-- Chartboost Corona SDK
-- Created by: Chris
--

local cmd = (...)
local mod_name
if cmd then mod_name = cmd:match( "^(.*)%..-$" ) end

local __chartboost__modules = {}
local function __chartboost__require__(name)
    local mod = __chartboost__modules[name]
    if mod then
        return __chartboost__modules[name]()
    else
        return require(name)
    end
end

-- these methods will be replaced in the build script - they don't actually do anything as is
__chartboost__declare("chartboost.libraries.lib.class")
__chartboost__declare("chartboost.libraries.CBUtility")
__chartboost__declare("chartboost.networking.CBWebImageCache")
__chartboost__declare("chartboost.networking.CBURLOpener")
__chartboost__declare("chartboost.model.CBImpressionType")
__chartboost__declare("chartboost.model.CBImpressionState")
__chartboost__declare("chartboost.model.CBOrientation")
__chartboost__declare("chartboost.model.CBAnimationType")
__chartboost__declare("chartboost.view.CBAnimations")
__chartboost__declare("chartboost.view.CBAnimationManager")
__chartboost__declare("chartboost.view.CBUnderfinedProgressBar")
__chartboost__declare("chartboost.view.CBLoadingView")
__chartboost__declare("chartboost.view.CBBackgroundView")
__chartboost__declare("chartboost.view.CBPopupImpressionView")
__chartboost__declare("chartboost.nativeviews.CBRoundRectImageView")
__chartboost__declare("chartboost.nativeviews.CBActionButton")
__chartboost__declare("chartboost.nativeviews.CBMoreAppsCell")
__chartboost__declare("chartboost.nativeviews.CBMoreAppsRegularCell")
__chartboost__declare("chartboost.nativeviews.CBMoreAppsFeaturedCell")
__chartboost__declare("chartboost.nativeviews.CBMoreAppsWebViewCell")
__chartboost__declare("chartboost.CBViewProtocol")
__chartboost__declare("chartboost.CBViewController")
__chartboost__declare("chartboost.nativeviews.CBNativeInterstitialViewProtocol")
__chartboost__declare("chartboost.nativeviews.CBMoreAppsViewProtocol")
__chartboost__declare("chartboost.view.CBWebViewProtocol")
__chartboost__declare("chartboost.model.CBImpression")

local exposed_modules = {}

-- these four classes are the mandatory interface for the public chartbooost corona code
-- everything else can be modified freely, but the methods in these three classes must remain functional
exposed_modules["chartboost.model.CBImpression"] = __chartboost__modules["chartboost.model.CBImpression"]
exposed_modules["chartboost.CBViewController"] = __chartboost__modules["chartboost.CBViewController"]
exposed_modules["chartboost.networking.CBWebImageCache"] = __chartboost__modules["chartboost.networking.CBWebImageCache"]
exposed_modules["chartboost.networking.CBURLOpener"] = __chartboost__modules["chartboost.networking.CBURLOpener"]

-- get internal library
local success, cb = pcall(require, mod_name .. ".chartboost_internal")
if (not success) then
    print "Chartboost requires the additional library file 'chartboost_internal.lua' to be found in the same directory as 'chartboost.lua'."
end

return cb(exposed_modules)