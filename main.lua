--
-- Chartboost Corona SDK
-- Created by: Chris
--

local widget = require "widget"
local cbdata = require "ChartboostSDK.chartboostdata"
local cb = require "ChartboostSDK.chartboost"

local background
local onOrientationChange = function(orientation)
    if background then background:removeSelf() end
    background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    background:setFillColor(96, 96, 255, 255)
    background:toBack()
end
onOrientationChange()
Runtime:addEventListener("orientation", onOrientationChange)

local appId = "4f7aa26ef77659d869000003"
local appSignature = "ee759deefd871ff6e2411c7153dbedefa4aabe38"
local delegate = {
    shouldRequestInterstitial = function(location) print("Chartboost: shouldRequestInterstitial " .. location .. "?"); return true end,
    shouldDisplayInterstitial = function(location) print("Chartboost: shouldDisplayInterstitial " .. location .. "?"); return true end,
    didCacheInterstitial = function(location) print("Chartboost: didCacheInterstitial " .. location); return end,
    didFailToLoadInterstitial = function(location) print("Chartboost: didFailToLoadInterstitial " .. location); return end,
    didDismissInterstitial = function(location) print("Chartboost: didDismissInterstitial " .. location); return end,
    didCloseInterstitial = function(location) print("Chartboost: didCloseInterstitial " .. location); return end,
    didClickInterstitial = function(location) print("Chartboost: didClickInterstitial " .. location); return end,
    didShowInterstitial = function(location) print("Chartboost: didShowInterstitial " .. location); return end,
    shouldDisplayLoadingViewForMoreApps = function() return true end,
    shouldRequestMoreApps = function() print("Chartboost: shouldRequestMoreApps"); return true end,
    shouldDisplayMoreApps = function() print("Chartboost: shouldDisplayMoreApps"); return true end,
    didCacheMoreApps = function() print("Chartboost: didCacheMoreApps"); return end,
    didFailToLoadMoreApps = function() print("Chartboost: didFailToLoadMoreApps"); return end,
    didDismissMoreApps = function() print("Chartboost: didDismissMoreApps"); return end,
    didCloseMoreApps = function() print("Chartboost: didCloseMoreApps"); return end,
    didClickMoreApps = function() print("Chartboost: didClickMoreApps"); return end,
    didShowMoreApps = function() print("Chartboost: didShowMoreApps"); return end,
    shouldRequestInterstitialsInFirstSession = function() return true end
}

cb.create{appId = appId,
    appSignature = appSignature,
    delegate = delegate,
    appVersion = "1.0",
    appBundle = "com.chartboost.cbtest"}
cb.startSession()

--[[ -- test the special sdk data methods
cbdata.cacheInterstitialData("Default", function(response)
    local ad_id = response["ad_id"]
    local link = response.link
    print ("Success requesting ad: "..tostring(link))
    cbdata.showInterstitialData(ad_id, function(response)
        print("Success showing ad "..ad_id)
    end, function(error)
        print("Error showing: "..error)
    end)
end, function(error)
    print("Error requesting: "..error)
end)
--]]

local showAd = widget.newButton{
    id = "showAd",
    left = 24, top = 24,
    label = "Show Interstitial",
    onRelease = function()
        local msg = "Chartboost: Loading Interstitial"
        if cb.hasCachedInterstitial() then
            msg = "Chartboost: Loading Interstitial From Cache"
        end
        print(msg)
        cb.showInterstitial()
        return true
    end
}

local cacheAd = widget.newButton{
    id = "cacheAd",
    left = 24, top = 72,
    label = "Preload Interstitial",
    onRelease = function()
        print("Chartboost: Caching Interstitial")
        cb.cacheInterstitial()
        return true
    end
}

local showMore = widget.newButton{
    id = "showMore",
    left = 172, top = 24,
    label = "Show More Apps",
    onRelease = function()
        local msg = "Chartboost: Loading More Apps"
        if cb.hasCachedMoreApps() then
            msg = "Chartboost: Loading More Apps From Cache"
        end
        print(msg)
        cb.showMoreApps()
        return true
    end
}

local cacheAd = widget.newButton{
    id = "cacheMore",
    left = 172, top = 72,
    label = "Preload More Apps",
    onRelease = function()
        print("Chartboost: Caching More Apps")
        cb.cacheMoreApps()
        return true
    end
}

local clearPreload = widget.newButton{
    id = "clearPreload",
    left = 24, top = 120,
    label = "Clear Preload Data",
    onRelease = function()
        print("Chartboost: Clearing preload ad data")
        cb.clearCache()
        cb.clearImageCache()
        return true
    end
}

local recordPurchase = widget.newButton{
    id = "recordPurchase",
    left = 172, top = 120,
    label = "Record Purchase",
    onRelease = function()
        print("Chartboost: Purchase Clicked!")
        local meta = {fakemeta1 = 5, fakemeta2 = "string"}
        cb.analyticsRecordPaymentTransaction(
            "OBJECT_001", "Test Object", 0.9928, "$", 1, meta)
        return true
    end
}

local trackEvent = widget.newButton{
    id = "trackEvent",
    left = 24, top = 168,
    label = "Track Event",
    onRelease = function()
        print("Chartboost: Track Event Clicked!")
        local meta = {fakeeventmeta1 = 5, fakeeventmeta2 = "string"}
        cb.analyticsTrackEvent("EventName", 5, meta)
        return true
    end
}

local forcedOrient = cb.orientations.UNSPECIFIED
local orientCycle = {
    [cb.orientations.UNSPECIFIED] = cb.orientations.PORTRAIT,
    [cb.orientations.PORTRAIT] = cb.orientations.LANDSCAPE,
    [cb.orientations.LANDSCAPE] = cb.orientations.PORTRAIT_REVERSE,
    [cb.orientations.PORTRAIT_REVERSE] = cb.orientations.LANDSCAPE_REVERSE,
    [cb.orientations.LANDSCAPE_REVERSE] = cb.orientations.UNSPECIFIED
}

local orientation
orientation = widget.newButton{
    id = "orientation",
    left = 24, top = 216,
    width = 272,
    label = "Forced Orientation: None",
    onRelease = function()
        forcedOrient = orientCycle[forcedOrient]
        orientation:setLabel("Forced Orientation: " .. forcedOrient.printName)
        cb.setOrientation(forcedOrient)
        return true
    end
}