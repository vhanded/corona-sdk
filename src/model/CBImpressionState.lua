--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This enum is used by internal Chartboost code!
-- Do not modify its public interface!
--
-- Enumeration of impression states
--

local ret = {
    CBImpressionStateOther = "CBImpressionStateOther",
    CBImpressionStateWaitingForDisplay = "CBImpressionStateWaitingForDisplay",
    CBImpressionStateDisplayedByDefaultController = "CBImpressionStateDisplayedByDefaultController",
    CBImpressionStateWaitingForDismissal = "CBImpressionStateWaitingForDismissal",
    CBImpressionStateWaitingForCaching = "CBImpressionStateWaitingForCaching",
    CBImpressionStateCached = "CBImpressionStateCached"
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