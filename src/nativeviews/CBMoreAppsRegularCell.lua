--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class wraps the creation of regular cells for the more apps page
-- Instantiate using CBMoreAppsRegularCell(cbProxy, cellMeta, position, onClick)
-- Call cell:getCell() to get the actual table to supply to the tableview widget.
--

local class = require "chartboost.libraries.lib.class"
local CBRoundRectImageView = require "chartboost.nativeviews.CBRoundRectImageView"
local CBActionButton = require "chartboost.nativeviews.CBActionButton"
local CBUtility = require "chartboost.libraries.CBUtility"
local CBMoreAppsCell = require "chartboost.nativeviews.CBMoreAppsCell"

local kCBNativeMoreAppsRegularIconSize = 50
local kCBNativeMoreAppsRegularMargin = 10

local CBMoreAppsRegularCell = class(function(self, cbProxy, cellMeta, position, onClick)
    assert(type(cbProxy) == "table", "First parameter 'cbProxy' must be a CBProxy.")
    self.cbProxy = cbProxy
    assert(type(cellMeta) == "table", "Second parameter 'cellMeta' must be a table.")
    assert(type(position) == "number", "Third parameter 'position' must be a number.")
    assert(type(onClick) == "function", "Fourth parameter 'onClick' must be a function.")
    local height = CBUtility.dpToPixels(kCBNativeMoreAppsRegularIconSize + 2 * kCBNativeMoreAppsRegularMargin)
    self.cell = CBMoreAppsCell.baseCell(height, onClick)
    local render = self.cell.onRender
    self.cell.onRender = function(event)
        render(event)
        local row = event.row
        local rowGroup = event.row

        local regularIconSize = CBUtility.dpToPixels(kCBNativeMoreAppsRegularIconSize)
        local regularMargin = CBUtility.dpToPixels(kCBNativeMoreAppsRegularMargin)

        local function createIcon(bitmap)
            local icon = CBRoundRectImageView(cbProxy, bitmap)
            icon.group:setReferencePoint(display.CenterReferencePoint)
            icon.group.xScale = regularIconSize / icon.group.contentWidth
            icon.group.yScale = regularIconSize / icon.group.contentHeight
            icon.group.x = regularMargin + regularIconSize / 2.0
            icon.group.y = row.height / 2.0
            rowGroup:insert(icon.group)
            row.icon = icon
        end

        local assets = cellMeta["assets"]
        if assets then
            local icon = assets["icon"]
            if icon then
                local data = {index = position}
                self.cbProxy.getImageCache():loadImageWithURL(icon["url"], icon["checksum"], createIcon, data)
            end
        end

        local btnText = cellMeta["deep-text"]
        if not btnText or btnText == "" then
            btnText = cellMeta["text"] or "VIEW"
        end
        local btn = CBActionButton(self.cbProxy, btnText, row.height - regularMargin * 3, onClick)
        btn.group.x = row.width - btn.group.contentWidth - regularMargin * 2
        btn.group.y = row.height * 0.5 - btn.group.contentHeight * 0.5
        row.btn = btn
        rowGroup:insert(btn.group)

        local text = cellMeta["name"] or "Unknown App"
        local textWidth = row.width - btn.group.contentWidth - regularMargin * 4 - regularIconSize
        local label = display.newText(rowGroup, text, 0, 0, textWidth, 0, native.systemFontBold, 16)
        label:setReferencePoint(display.CenterLeftReferencePoint)
        label.x = regularMargin + regularIconSize + regularMargin * 0.75
        label.y = row.height * 0.5
        label:setTextColor(0, 0, 0, 255)
        row.label = label

        local delta = CBUtility.dpToPixels(1)
        local labelShadow = display.newText(rowGroup, text, 0, 0, textWidth, 0, native.systemFontBold, 16)
        labelShadow:setReferencePoint(display.CenterLeftReferencePoint)
        labelShadow.x = regularMargin + regularIconSize + regularMargin * 0.75 + delta
        labelShadow.y = row.height * 0.5 + delta
        labelShadow:setTextColor(0, 0, 0, 64)
        row.labelShadow = labelShadow
        row.label:toFront()
    end
end)

function CBMoreAppsRegularCell:getCell()
    return self.cell
end

return CBMoreAppsRegularCell