The Chartboost SDK is the cornerstone of our network: It provides the functionality for showing ads and More Apps pages, and supplies our analytics system with detailed information about campaign performance. 

---
Adding the SDK to your games is quick and easy &mdash; you just need a few ingredients:
- A Chartboost account
- An app in your dashboard
- [The latest SDK](/downloads/corona)
- [An active campaign](/documentation/publishing)

---
Requirements:
- A recent Corona release (public release 2013.1137 or higher)
- You must create separate apps via [the Chartboost dashboard](https://dashboard.chartboost.com/app/edit) for iOS and Android builds
- The Corona SDK only works with games running on iOS 6.0+ devices. This OS restriction should be applied to all publishing and advertising campaigns via the Chartboost dashboard.
- For Android games, **do not** enable the `android.permission.READ_PHONE_STATE` permission &mdash; it prevents your game from sending Android IDs to our system
- The Chartboost start session call, `cb.startSession()`, **must not** be dependent on user actions or any prior network requests
- The Chartboost start session call, `cb.startSession()`, **must** be called every time your app becomes active (on both hard and &mdash; for iOS games &mdash; soft bootups)

---
###Basic Integration: Quick Start Guide

To get started, add `chartboost.lua`, `chartboost_internal.lua`, and the seven included image files to your project (in the root or any single sub-directory).

Next, import the Chartboost SDK into any source file that uses Chartboost, and set an instance variable. No matter where you get the Chartboost instance, it will be the same exact object. Importing the library will not pollute the `globals` table at all.

```lua
local cb = require "chartboost"
```

After that, add the following to the section of your code where you initialize things:

```lua 
-- Initialize Chartboost
cb.create{appId = "YOUR_APP_ID",
    appSignature = "YOUR_APP_SIGNATURE",
    delegate = nil,
    appBundle = "YOUR_APP_BUNDLE"} -- ios bundle or android package name
	
-- Notify the beginning of a user session
cb.startSession()
	
-- Show an interstitial
cb.showInterstitial() 
```

For more granular control over Chartboost, pass in a table of functions as the delegate in the `create` method above. The following is a complete delegate table. The methods are all optional &mdash; you'll only need to implement the ones your game will use. (Each method below that returns a boolean defaults to `true` if no function is provided.)

```lua
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
```

There are a number of actions that the Chartboost SDK can perform.  The following code demonstrates them all:

```lua
-- notify the beginning of a user session
cb.startSession()
	
-- show / cache interstitials
cb.showInterstitial(location) -- location is optional
cb.cacheInterstitial(location) -- location is optional
local interstitialCached = cb.hasCachedInterstitial(location) -- returns boolean, location is optional
	
-- show / cache more apps
cb.showMoreApps()
cb.cacheMoreApps()
local moreAppsCached = cb.hasCachedMoreApps() - returns boolean
	
-- clear cached impressions
cb.clearCache()
	
-- clear cached images from device
cb.clearImageCache()
	
-- record payment transaction
-- parameters are in order: string, string, number, string, number (decimal will be truncated), table of extra data
cb.analyticsRecordPaymentTransaction(sku, title, price, currency, quantity, meta)
	
-- track arbitrary event
-- parameters are in order: string, number, table of extra data
cb.analyticsTrackEvent(eventIdentifier, value, meta)
	
-- identity tracking
cb.setIdentityTrackingDisabledOnThisDevice(disabled)
local disabled = cb.isIdentityTrackingDisabledOnThisDevice()
	
-- get the current orientation of the device, or if it exists, the overridden orientation of impressions
local orientation = cb.getOrientation() -- returns an orientation table, see below
	
-- set the overridden orientation of impressions. use orientations.UNSPECIFIED or nil to remove any override.
cb.setOrientation(orientation)
	
-- get the angular difference caused by an orientation override
local diff = cb.getForcedOrientationDifference() -- returns a difference table, see below
	
-- cb.orientations stores each of the possible screen orientation
-- each orientation is a table, with an example as follows:
-- {type = "CBOrientation", name = "PORTRAIT", printName = "Portrait", angle = 0}
-- the tables also have some methods available, which are: isPortrait(), isLandscape(), rotate90(), rotate180(), rotate270()
local orientation = cb.orientations.UNSPECIFIED -- no specific orientation
orientation = cb.orientations.PORTRAIT
orientation = cb.orientations.LANDSCAPE
orientation = cb.orientations.PORTRAIT_REVERSE
orientation = cb.orientations.LANDSCAPE_REVERSE
	
-- cb.differences stores each of the possible angular differences
-- each difference is a table, with an example as follows:
-- {type = "CBDifference", name = "ANGLE_0", diff = 0}
-- the tables also have some methods available, which are:
--		isOdd() -- true when the angle is 90 or 270
--		isReverse() -- true when the angle is 180 or 270
--		flipIfOdd(x, y) -- if isOdd() returns true, returns y, x. otherwise, returns x, y.
local diff = cb.differences.ANGLE_0
diff = cb.differences.ANGLE_90
diff = cb.differences.ANGLE_180
diff = cb.differences.ANGLE_270
```

---
Questions? We're happy to help &mdash; just drop us a line at <support@chartboost.com>.
