
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

local function main()
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    local frameSize = glview:getFrameSize()
    print(frameSize.height, frameSize.width)

    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
