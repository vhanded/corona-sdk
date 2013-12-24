--
-- Chartboost Corona SDK
-- Created by: Chris
--
-- This class manages the caching of images retrieved over the network
--

local lfs = require "lfs"

local class = require "chartboost.libraries.lib.class"

-- DO NOT CHANGE THESE VALUES, THEY ARE USED INTERNALLY AS WELL!
local kCBChartboostFolder = "__chartboost"
local kCBImagesSubFolder = "images"

local PARAM_NO_MEMORY_CACHE = "paramNoMemoryCache"

local sequence = 0

local CBWebImageCache = class(function(self)
    self.fileCache = {}  -- this is a table of functions that generate image DisplayObjects
    self.pendingDelegates = {}
end)

function CBWebImageCache:clearCache()
    -- remove anything from this session first
    for k,v in pairs(self.fileCache) do
        v:delete()
    end
    self.fileCache = {}

    -- find anything left over from old sessions
    local doc_path = system.pathForFile(kCBChartboostFolder
            .. "/" .. kCBImagesSubFolder, system.TemporaryDirectory)

    -- but first make sure the image cache even exists
    local success = lfs.chdir(doc_path)
    if not success then
        return
    end

    for file in lfs.dir(doc_path) do
        local theFile = doc_path .. "/" .. file;
        if lfs.attributes(theFile, "mode") == "file" then
            os.remove(theFile)
        end
    end
end

-- params: string, string, CBWebImageProtocol, table
function CBWebImageCache:loadImageWithURL(url, hexSHA1Checksum, delegate, data)
    assert(type(url) == "string", "First parameter 'url' must be a string.")
    assert(type(hexSHA1Checksum) == "string", "Second parameter 'checksum' must be a string.")
    assert(type(delegate) == "function", "Third parameter 'delegate' must be a function.")
    if data then assert(type(data) == "table", "Fourth parameter 'data' must be a table.") end

    -- check in the "memory cache" first
    local cachedBitmap
    --local noMemoryCache = data[PARAM_NO_MEMORY_CACHE] or false --unused currently

    cachedBitmap = self.fileCache[hexSHA1Checksum]
    if not cachedBitmap then
        cachedBitmap = self:readCachedBitmapFromDisk(hexSHA1Checksum)
    end
    self.fileCache[hexSHA1Checksum] = cachedBitmap

    if cachedBitmap then
        if delegate then
            delegate(cachedBitmap, data)
        end
        return
    end

    local function networkListener(event)
        local bitmap
        if (event.isError) then
            -- UNCOMMENT TO AID WITH DEBUGGING!
            -- print("ImageDownloader: Error " .. tostring(event.status) .. " while retrieving bitmap from " .. url)
        else
            bitmap = self:readCachedBitmapFromDisk(hexSHA1Checksum)
            self.fileCache[hexSHA1Checksum] = bitmap
        end

        local delegates = self.pendingDelegates[hexSHA1Checksum]
        self.pendingDelegates[hexSHA1Checksum] = nil
        if delegates then
            for i,v in ipairs(delegates) do
                v(bitmap, data)
            end
        end
    end
    local delegates = self.pendingDelegates[hexSHA1Checksum]
    if not delegates then
        delegates = {delegate }

        -- ensure image directory exists (<temp>/__chartboost/images/)
        local success = lfs.chdir(system.pathForFile(kCBChartboostFolder, system.TemporaryDirectory))
        if not success then
            lfs.chdir(system.pathForFile("", system.TemporaryDirectory))
            lfs.mkdir(kCBChartboostFolder)
        end
        success = lfs.chdir(system.pathForFile(kCBChartboostFolder
                .. "/" .. kCBImagesSubFolder, system.TemporaryDirectory))
        if not success then
            lfs.chdir(system.pathForFile(kCBChartboostFolder, system.TemporaryDirectory))
            lfs.mkdir(kCBImagesSubFolder)
        end
        network.download(url, "GET", networkListener, self:fileName(hexSHA1Checksum), system.TemporaryDirectory)
    else
        delegates[#delegates + 1] = delegate
    end
    self.pendingDelegates[hexSHA1Checksum] = delegates
end

function CBWebImageCache:fileName(checksum)
    return kCBChartboostFolder .. "/" .. kCBImagesSubFolder .. "/" .. checksum .. ".png"
end

local function fileExists(theFile, path)
    local thePath = path or system.DocumentsDirectory
    local filePath = system.pathForFile(theFile, thePath)
    local file = io.open(filePath, "r")

    if file then
        io.close(file)
        return true
    end
    return false
end


local function getCreativeSize(sequence)

    if display.contentWidth > display.contentHeight then
        if sequence == 1 then
            return 390, 200    
        else
            return 480, 320
        end
    else
        if sequence == 1 then
            return 320, 480    
        else
            return 240, 350
        end
    end
end




function CBWebImageCache:readCachedBitmapFromDisk(checksum)
    assert(type(checksum) == "string", "First parameter 'checksum' must be a string.")
    local fileName = self:fileName(checksum)
    if not fileExists(fileName, system.TemporaryDirectory) then
        return nil
    else
        local mt = {__call = function() 
            
            sequence = sequence + 1
            -- if sequence is 0, it is background
            print("filename", fileName, sequence)
            if sequence == 1 or sequence == 2 then

                -- change to new image rect, and specify size
                local width, height = getCreativeSize(sequence)
                return display.newImageRect(fileName, system.TemporaryDirectory, width, height)
            else
                sequence = 0
                return display.newImage(fileName, system.TemporaryDirectory)
            end

        end }
        local t = {checksum = checksum,
                   fileName = fileName,
                   filePath = system.pathForFile(fileName, system.TemporaryDirectory),
                   delete = function(self)
                       local success, reason = os.remove(self.filePath)
                       -- UNCOMMENT TO AID WITH DEBUGGING!
                       -- if not success then print("error deleting " .. self.filePath .. " because: " .. reason) end
                   end}
        setmetatable(t, mt)
        return t
    end
end

CBWebImageCache.PARAM_NO_MEMORY_CACHE = PARAM_NO_MEMORY_CACHE
return CBWebImageCache