corona-sdk
==========

##### 2013-07-15 Update

* The more apps page is now fixed! 
* The SDK has been recompiled so it no longer requires the chartboostlib.lua file.

-----

__IMPORTANT:__ This is a beta build! Please test thoroughly before releasing! You must create different Apps on the Chartboost dashboard for iOS and Android builds.

#### iOS

Things to note:

* This will only work for iOS 6.0+. This restriction needs to be set in all publishign and advertising campaigns on the dashboard.

#### Android

This won't work if you have the android.permission.READ_PHONE_STATE permission enabled.

-----

### Usage

Integrating Chartboost takes a few easy steps:

Make sure your app fits the minimum requirements:
- A recent version of Corona SDK (public release 2013.1137 or higher)

 1. Add `chartboost.lua` to your project (in the root or any subdirectory).

 2. Import the Chartboost SDK into any source file that uses Chartboost and set an instance variable.  No matter where you get the Chartboost instance, it will be the same exact object.  Importing the library will not pollute the globals table at all.
    
    ```lua
    local cb = require "chartboost"
    ```
    
 3. Add the following code somewhere that you initialize things:

  ```lua 
	-- Initialize Chartboost
	cb.create{appId = "YOUR_APP_ID",
		appSignature = "YOUR_APP_SIGNATURE",
		delegate = nil,
		appVersion = "YOUR_APP_VERSION"}
	
	-- Notify the beginning of a user session
	cb.startSession()
	
	-- Show an interstitial
	cb.showInterstitial() 
	```


 4. If you would like finer control over Chartboost, pass in a table of functions as the delegate in the create method above. The following is a complete delegate table.  The methods are all optional -- you need only implement the ones you want.  Finally, each method below that returns a boolean defaults to true if no function is provided.

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

 5. There are a number of actions that the Chartboost SDK can perform.  The following code demonstrates them all:
 
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
==========
Your feedback is welcome at support@chartboost.com!
