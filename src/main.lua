
require "cocos.init"

--设计分辨率大小
local designResolutionSize = cc.size(320, 568)

--三种资源大小
local smallResolutionSize = cc.size(640, 1136)
local largeResolutionSize = cc.size(750, 1334)

-- cclog
cclog = function(...)
    print(string.format(...))
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    ----------------
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()

    local sharedFileUtils = cc.FileUtils:getInstance()
    sharedFileUtils:addSearchPath("src")
    sharedFileUtils:addSearchPath("res")

    local searchPaths = sharedFileUtils:getSearchPaths()
    local resPrefix = "res/"

    --屏幕大小
    local frameSize = glview:getFrameSize()

    -- 如果屏幕分辨率高度大于small尺寸的资源分辨率高度，选择large资源。
    if frameSize.height > smallResolutionSize.height then
        director:setContentScaleFactor(math.min(largeResolutionSize.height / designResolutionSize.height, largeResolutionSize.width / designResolutionSize.width))
        table.insert(searchPaths, 1, resPrefix .. "large")
        --如果屏幕分辨率高度小等于small尺寸的资源分辨率高度，选择small资源。
    else
        director:setContentScaleFactor(math.min(smallResolutionSize.height / designResolutionSize.height, smallResolutionSize.width / designResolutionSize.width))
        table.insert(searchPaths, 1, resPrefix .. "small")
    end
    --设置资源搜索路径
    sharedFileUtils:setSearchPaths(searchPaths)

    -- 设置设计分辨率策略
    glview:setDesignResolutionSize(designResolutionSize.width, designResolutionSize.height, cc.ResolutionPolicy.FIXED_WIDTH)

    --设置是否显示帧率和精灵个数
    director:setDisplayStats(true)

    --设置帧率
    director:setAnimationInterval(1.0 / 60)

    --创建场景
    local scene = require("LoadingScene")
    local loadingScene = scene.create()

    if director:getRunningScene() then
        director:replaceScene(loadingScene)
    else
        director:runWithScene(loadingScene)
    end
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
