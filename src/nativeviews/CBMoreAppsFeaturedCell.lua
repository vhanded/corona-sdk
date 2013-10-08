--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class wraps the creation of featured cells for the more apps page
-- Instantiate using CBMoreAppsFeaturedCell(cbProxy, cellMeta, position, onClick)
-- Call cell:getCell() to get the actual table to supply to the tableview widget.
--

local class = require "chartboost.libraries.lib.class"
local CBRoundRectImageView = require "chartboost.nativeviews.CBRoundRectImageView"
local CBUtility = require "chartboost.libraries.CBUtility"
local CBMoreAppsCell = require "chartboost.nativeviews.CBMoreAppsCell"

local kCBNativeMoreAppsFeaturedCellAssetHeight = 100
local kCBNativeMoreAppsFeaturedCellMargin = 5

local CBMoreAppsFeaturedCell = class(function(self, cbProxy, cellMeta, position, onClick)
    assert(type(cbProxy) == "table", "First parameter 'cbProxy' must be a CBProxy.")
    self.cbProxy = cbProxy
    assert(type(cellMeta) == "table", "Second parameter 'cellMeta' must be a table.")
    assert(type(position) == "number", "Third parameter 'position' must be a number.")
    assert(type(onClick) == "function", "Fourth parameter 'onClick' must be a function.")

    local height = CBUtility.dpToPixels(kCBNativeMoreAppsFeaturedCellAssetHeight + 2 * kCBNativeMoreAppsFeaturedCellMargin)
    self.cell = CBMoreAppsCell.baseCell(height, onClick)
    local render = self.cell.onRender
    self.cell.onRender = function(event)
        render(event)
        local row = event.row
        local rowGroup = event.row
        local isPortrait = self.cbProxy.getOrientation().isPortrait()
        local assets = cellMeta["assets"]
        if assets then
            local icon
            if isPortrait then
                icon = assets["portrait"]
            else
                icon = assets["landscape"]
            end

            local regularMargin = CBUtility.dpToPixels(kCBNativeMoreAppsFeaturedCellMargin)

            local function createIcon(bitmap)
                local image = CBRoundRectImageView(cbProxy, bitmap)
                image.yScale = icon.contentHeight / (row.height - regularMargin * 2)
                image.xScale = image.yScale
                image.x = row.width / 2.0
                image.y = row.height / 2.0
                rowGroup:insert(image.group)
                row.image = image
            end

            if icon then
                local data = { index = position }
                self.cbProxy.getImageCache():loadImageWithURL(icon["url"], icon["checksum"], createIcon, data)
            end
        end
    end
end)

function CBMoreAppsFeaturedCell:getCell()
    return self.cell
end

return CBMoreAppsFeaturedCell
