--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This file is used to create rows for the more apps view.
-- Returns a table with a single method:
--   moreAppsCell.baseCell(rowHeight, onClick)
--   Supply a height and a method to listen for clicks and the method returns a row for use in tableview widgets
--

local COLOR_GRADIENT_TOP = {0xE9/255, 0xE9/255, 0xE9/255}
local COLOR_GRADIENT_BOTTOM = {0xDC/255, 0xDC/255, 0xDC/255}

local function baseCell(rowHeight, onClick)
    assert(type(rowHeight) == "number", "First parameter 'rowHeight' must be a number.")
    assert(type(onClick) == "function", "Second parameter 'onClick' must be a function.")
    local function onRowTouch(event)
        local row = event.target

        if event.phase == "release" then
            if not row.isCategory then
                -- reRender property tells row to refresh if still onScreen when content moves
                row.reRender = true
                onClick()
            end
        end
        return true
    end

    local function onRowRender(event)
        local row = event.row
        local rowGroup = event.row

        -- gradient BG
        local bg = display.newRect(rowGroup, 0, 0, row.width, row.height)
        local gradient = graphics.newGradient(COLOR_GRADIENT_TOP, COLOR_GRADIENT_BOTTOM)
        bg:setFillColor(gradient)
        bg.x = display.contentCenterX; bg.y = display.contentCenterY;

        -- borders
        local borderTop = display.newRect(rowGroup, 0, 0, row.width, 1)
        borderTop:setFillColor(0xF4/255, 0xF4/255, 0xF4/255, 255/255)
        local borderBottom = display.newRect(rowGroup, 0, row.height - 1, row.width, 1)
        borderBottom:setFillColor(0xCC/255, 0xCC/255, 0xCC/255, 255/255)
    end

    return {
        onTouch = onRowTouch,
        onRender = onRowRender,
        rowHeight = rowHeight,
        isCategory = false,
        lineColor = {0, 0, 0, 255/255}
    }
end

return {baseCell = baseCell}