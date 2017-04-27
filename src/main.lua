
require "cocos.init"

--��Ʒֱ��ʴ�С
local designResolutionSize = cc.size(320, 568)

--������Դ��С
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

    --��Ļ��С
    local frameSize = glview:getFrameSize()

    -- �����Ļ�ֱ��ʸ߶ȴ���small�ߴ����Դ�ֱ��ʸ߶ȣ�ѡ��large��Դ��
    if frameSize.height > smallResolutionSize.height then
        director:setContentScaleFactor(math.min(largeResolutionSize.height / designResolutionSize.height, largeResolutionSize.width / designResolutionSize.width))
        table.insert(searchPaths, 1, resPrefix .. "large")
        --�����Ļ�ֱ��ʸ߶�С����small�ߴ����Դ�ֱ��ʸ߶ȣ�ѡ��small��Դ��
    else
        director:setContentScaleFactor(math.min(smallResolutionSize.height / designResolutionSize.height, smallResolutionSize.width / designResolutionSize.width))
        table.insert(searchPaths, 1, resPrefix .. "small")
    end
    --������Դ����·��
    sharedFileUtils:setSearchPaths(searchPaths)

    -- ������Ʒֱ��ʲ���
    glview:setDesignResolutionSize(designResolutionSize.width, designResolutionSize.height, cc.ResolutionPolicy.FIXED_WIDTH)

    --�����Ƿ���ʾ֡�ʺ;������
    director:setDisplayStats(true)

    --����֡��
    director:setAnimationInterval(1.0 / 60)

    --��������
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
