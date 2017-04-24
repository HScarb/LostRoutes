
-- cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("res/hd")
cc.FileUtils:getInstance():addSearchPath("res/fonts")
cc.FileUtils:getInstance():addSearchPath("res/particle")
cc.FileUtils:getInstance():addSearchPath("res/sound")

require "config"
require "cocos.init"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__( msg )
    cclog("--------------------------------------")
    cclog("LUA-ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("--------------------------------------")
    return msg
end

local function main()
    -- require("app.MyApp"):create():run()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- initialize director
    local director = cc.director:getInstance()
    
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
