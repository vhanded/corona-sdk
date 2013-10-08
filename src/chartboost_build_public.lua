--
-- Chartboost Corona SDK
-- Created by: Chris
--

local base = io.open("chartboost_lib_public.lua", "r")
local contents = base:read("*all")

print("Creating Chartboost public library portion...")

contents = contents:gsub("__chartboost__declare%(\"(.-)\"%)",
    function(modname)
        local modfile = modname:gsub("%.", "/") .. ".lua"
        modfile = modfile:gsub("chartboost/", "")
        print("  Assembling public library component: " .. modfile)
        local sub = io.open(modfile, "r")
        local subContents = sub:read("*all")
        subContents = subContents:gsub("require \"(.-)\"",
            "__chartboost__require__(\"%1\")");
        subContents = subContents:gsub("require%s*%(%s*(.-)%s*%)",
            "__chartboost__require__(%1)");
        return "__chartboost__modules[\"" .. modname .. "\"] = function()\n" .. subContents .. "\nend"
    end)

print("  Compiling public library portion...")

local output = io.open("chartboost_library_public.lua", "w")
output:write(contents)
output:close()