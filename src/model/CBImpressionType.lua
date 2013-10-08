--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This enum is used by internal Chartboost code!
-- Do not modify its public interface!
--
-- Enumeration of impression types
--

local ret = {
    CBImpressionTypeOther = "CBImpressionTypeOther",
    CBImpressionTypeInterstitial = "CBImpressionTypeInterstitial",
    CBImpressionTypeMoreApps = "CBImpressionTypeMoreApps"
}

ret.assert = function(imp)
    for k,v in pairs(ret) do
        if v == imp then
            return true
        end
    end
    return false
end

return ret