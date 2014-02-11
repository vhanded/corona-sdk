local cb = require ("vendor.chartboostSDK.dist.chartboost")


local chartBoostHelper = {}


local genericCallback = nil

local delegate = {
    shouldRequestInterstitial   = function(location) genericCallback({status = "shouldRequestInterstitial"}); print("Chartboost: shouldRequestInterstitial " .. location .. "?"); return true end,
    shouldDisplayInterstitial   = function(location) genericCallback({status = "shouldDisplayInterstitial"}); print("Chartboost: shouldDisplayInterstitial " .. location .. "?"); return true end,
    didCacheInterstitial        = function(location) genericCallback({status = "didCacheInterstitial"}); print("Chartboost: didCacheInterstitial " .. location); return end,
    didFailToLoadInterstitial   = function(location) genericCallback({status = "didFailToLoadInterstitial"}); print("Chartboost: didFailToLoadInterstitial " .. location); return end,
    didDismissInterstitial      = function(location) genericCallback({status = "didDismissInterstitial"}); print("Chartboost: didDismissInterstitial " .. location); return end,
    didCloseInterstitial        = function(location) genericCallback({status = "didCloseInterstitial"}); print("Chartboost: didCloseInterstitial " .. location); return end,
    didClickInterstitial        = function(location) genericCallback({status = "didClickInterstitial"}); print("Chartboost: didClickInterstitial " .. location); return end,
    didShowInterstitial         = function(location) genericCallback({status = "didShowInterstitial"}); print("Chartboost: didShowInterstitial " .. location); return end,
    shouldDisplayLoadingViewForMoreApps = function() return true end,
    shouldRequestMoreApps       = function() genericCallback({status = "shouldRequestMoreApps"}); print("Chartboost: shouldRequestMoreApps"); return true end,
    shouldDisplayMoreApps       = function() genericCallback({status = "shouldDisplayMoreApps"}); print("Chartboost: shouldDisplayMoreApps"); return true end,
    didCacheMoreApps            = function() genericCallback({status = "didCacheMoreApps"}); print("Chartboost: didCacheMoreApps"); return end,
    didFailToLoadMoreApps       = function() genericCallback({status = "didFailToLoadMoreApps"}); print("Chartboost: didFailToLoadMoreApps"); return end,
    didDismissMoreApps          = function() genericCallback({status = "didDismissMoreApps"}); print("Chartboost: didDismissMoreApps"); return end,
    didCloseMoreApps            = function() genericCallback({status = "didCloseMoreApps"}); print("Chartboost: didCloseMoreApps"); return end,
    didClickMoreApps            = function() genericCallback({status = "didClickMoreApps"}); print("Chartboost: didClickMoreApps"); return end,
    didShowMoreApps             = function() genericCallback({status = "didShowMoreApps"}); print("Chartboost: didShowMoreApps"); return end,
    shouldRequestInterstitialsInFirstSession = function() return true end
}





function chartBoostHelper.init(appId, appSignature, bundleId)

    cb.create{appId = appId,
        appSignature = appSignature,
        delegate = delegate,
        appVersion = system.getInfo("appVersionString"),
        appBundle = bundleId
    }
    cb.startSession()
end



--------------------------------------------------------------------------------
-- show ad
--------------------------------------------------------------------------------
function chartBoostHelper.showAd(callback)
    
    genericCallback = callback
    
    if not chartBoostHelper.isAdDisabled then
        cb.showInterstitial()
    else
        callback({status = "didFailToLoadInterstitial"})
    end
end




--------------------------------------------------------------------------------
-- cache ad
--------------------------------------------------------------------------------
function chartBoostHelper.cacheAd()
    cb.cacheInterstitial()
end




return chartBoostHelper