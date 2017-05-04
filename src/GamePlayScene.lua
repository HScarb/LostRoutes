
-- 主游戏层
local mainLayer

local Enemy = require("Sprite.Enemy")
local Fighter = require("Sprite.Fighter")
local Bullet = require("Sprite.Bullet")

local schedulerId = nil
local scheduler = cc.Director:getInstance():getScheduler()

local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local touchFighterListener
local contactListener

local fighter
-- 暂停菜单
local menu

-- 分数
local score = 0

local GamePlayScene = class("GamePlayScene", function()
    local scene = cc.Scene:createWithPhysics()
    -- 0, 0不受重力的影响
    scene:getPhysicsWorld():setGravity(cc.p(0,0))
    return scene
end)


function GamePlayScene.create()
    local scene = GamePlayScene.new()
    return scene
end

function GamePlayScene:ctor()
    cclog("GamePlayScene init")

    self:addChild(self:createInitBGLayer())
    -- 场景生命周期事件处理
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif event == "exit" then
            self:onExit()
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        elseif event == "cleanup" then
            self:cleanup()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- create 背景层

function GamePlayScene:createInitBGLayer()
    cclog("create init BG layer")
    local bgLayer = cc.Layer:create()

    local bg = cc.TMXTiledMap:create("map/blue_bg.tmx")
    bgLayer:addChild(bg)

    -- 放置发光粒子背景
    local ps = cc.ParticleSystemQuad:create("particle/light.plist")
    ps:setPosition(cc.p(size.width / 2, size.height / 2))
    bgLayer:addChild(ps, 0, GameSceneNodeTag.BatchBackground)

    -- 添加背景精灵1
    local sprite1 = cc.Sprite:createWithSpriteFrameName("gameplay.bg.sprite-1.png")
    sprite1:setPosition(cc.p(-50, -50))
    bgLayer:addChild(sprite1, 0, GameSceneNodeTag.BatchBackground)

    local ac1 = cc.MoveBy:create(20, cc.p(500, 600))
    local ac2 = ac1.reverse()
    local as1 = cc.Sequence:create(ac1, ac2)
    sprite1:runAction(cc.RepeatForever:create(cc.EaseSineInOut:create(as1)))

    -- 添加背景精灵2
    local sprite2 = cc.Sprite:createWithSpriteFrameName("gameplay.bg.sprite-2.png")
    sprite2:setPosition(cc.p(size.width, 0))
    bgLayer:addChild(sprite2, 0, GameSceneNodeTag.BatchBackground)

    local ac3 = cc.MoveBy:create(10, cc.p(-500, 600))
    local ac4 = ac3:reverse()
    local as2 = cc.Sequence:create(ac3, ac4)
    sprite2:runAtion(cc.RepeatForever:create(cc.EaseExponentialInOut:create(as2)))

    return bgLayer
end

-- 创建Main层
function GamePlayScene:createLayer()
    -- ...
end

-- 处理玩家与敌人的接触检测
function GamePlayScene:handleFighterCollidingWithEnemy()
    
end

--炮弹与敌人的接触检测
function GamePlayScene:handleBulletCollidingWithEnemy(enemy)
    
end

function GamePlayScene:onEnterTransitionFinish()
    cclog("GamePlayScene onEnterTransitionFinish")
    if defaults:getBoolForKey(MUSIC_KEY) then
        AudioEngine.playMusic(bg_music_2, true)
    end
end

function GamePlayScene:onExit()
    cclog("GamePlayScene onExit")
    -- 停止游戏调度
    if schedulerId ~= nil then
        scheduler:unscheduleScriptEntry(schedulerId)
    end
    -- 注销事件监听器
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if nil ~= touchFighterListener then
        eventDispatcher:removeEventListener(touchFighterListener)
    end
    if nil ~= contactListener then
        eventDispatcher:removeEventListener(contactListener)
    end

    -- 删除layer节点以及其子节点
    mainLayer:removeAllChildren()
    mainLayer:removeFromParent()
    mainLayer = nil
end

function GamePlayScene:onExitTransitionStart()
    cclog("GamePlayScene onExitTransitionStart")
end

function GamePlayScene:cleanup()
    cclog("GamePlayScene cleanup")
end

return GamePlayScene