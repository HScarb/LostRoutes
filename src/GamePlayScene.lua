
-- ����Ϸ��
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
-- ��ͣ�˵�
local menu

-- ����
local score = 0
-- ����ռλ��
local scorePlaceholder = 0

local GamePlayScene = class("GamePlayScene", function()
    local scene = cc.Scene:createWithPhysics()
    -- 0, 0����������Ӱ��
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
    -- �������������¼�����
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

-- ����������
function GamePlayScene:createInitBGLayer()
    cclog("create init BG layer")
    local bgLayer = cc.Layer:create()

    local bg = cc.TMXTiledMap:create("map/blue_bg.tmx")
    bgLayer:addChild(bg)

    -- ���÷������ӱ���
    local ps = cc.ParticleSystemQuad:create("particle/light.plist")
    ps:setPosition(cc.p(size.width / 2, size.height / 2))
    bgLayer:addChild(ps, 0, GameSceneNodeTag.BatchBackground)

    -- ��ӱ�������1
    local sprite1 = cc.Sprite:createWithSpriteFrameName("gameplay.bg.sprite-1.png")
    sprite1:setPosition(cc.p(-50, -50))
    bgLayer:addChild(sprite1, 0, GameSceneNodeTag.BatchBackground)

    local ac1 = cc.MoveBy:create(20, cc.p(500, 600))
    local ac2 = ac1.reverse()
    local as1 = cc.Sequence:create(ac1, ac2)
    sprite1:runAction(cc.RepeatForever:create(cc.EaseSineInOut:create(as1)))

    -- ��ӱ�������2
    local sprite2 = cc.Sprite:createWithSpriteFrameName("gameplay.bg.sprite-2.png")
    sprite2:setPosition(cc.p(size.width, 0))
    bgLayer:addChild(sprite2, 0, GameSceneNodeTag.BatchBackground)

    local ac3 = cc.MoveBy:create(10, cc.p(-500, 600))
    local ac4 = ac3:reverse()
    local as2 = cc.Sequence:create(ac3, ac4)
    sprite2:runAtion(cc.RepeatForever:create(cc.EaseExponentialInOut:create(as2)))

    return bgLayer
end

-- ����Main��
function GamePlayScene:createLayer()
    mainLayer = cc.Layer:create()

    -- �����ʯ1
    local stone1 = Enemy.create(EnemyTypes.Enemy_Stone)
    mainLayer:addChild(stone1)

    -- �������
    local planet = Enemy.create(EnemyTypes.Enemy_Planet)
    mainLayer:addChild(planet)

    -- ��ӵл�1
    local enemyFighter1 = Enemy.create(EnemyTypes.Enemy_1)
    mainLayer:addChild(enemyFighter1, 10, GameSceneNodeTag.Enemy)

    -- ��ӵл�2
    local enemyFighter2 = Enemy.create(EnemyTypes.Enemy_2)
    mainLayer:addChild(enemyFighter2, 10, GameSceneNodeTag.Enemy)

    fighter = Fighter.create("gameplay.fighter.png")
    fighter:setPos(cc.p(size.width / 2, 70))
    mainLayer:addChild(fighter, 10, GameSceneNodeTag.Fighter)

    -- ��ʼ��Ϸ����
    local function shootBullet()
        if nil ~= fighter and fighter:isVisible() then
            local bullet = Bullet.create("gameplay.bullet.png")
            mainLayer:addChild(bullet, 0, GameSceneNodeTag.Bullet)
        end
    end
    -- ...

    -- �����¼��ص�����
    local function touchBegan(touch, event)
        return true
    end

    -- �����¼��ص�����
    local function touchMoved(touch, event)
        -- ��ȡ�¼����󶨵�node
        local node = event:getCurrentTarget()

        local currentPosX, currentPosY = node:getPosition()
        local diff = touch:getDelta()
        -- �ƶ���ǰ�������������λ��
        node:setPos(cc.p(currentPosX + diff.x, currentPosY + diff.y))
    end

    -- ������ҳ�˵��ص�����
    local function menuBackCallback(sender)
        cclog("menuBackCallback")
        cc.Director:getInstance():popScene()
        if defaults:getBoolForKey(SOUND_KEY) then
            AudioEngine.playEffect(sound_1)
        end
    end

    -- �����˵��ص�����
    local function menuResumeCallback()
        cclog("menuResumeCallback")
        if defaults:getBoolForKey(SOUND_KEY) then
            AudioEngine.playEffect(sound_1)
        end

        mainLayer:resume()              -- ������ǰ���NodeԪ��
        schedulerId = nil
        schedulerId = scheduler:scheduleScriptFunc(shootBullet, 0.2, false)     -- ������Ϸ����,���ظõ��ȵ�id,����ֹͣ����
        
        -- layer�ӽڵ����
        local pChildren = mainLayer:getChildren()
        for i = 1, #pChildren, 1 do
            local child = pChildren[i]
            child:resume()
        end
        mainLayer:removeChild(menu)
    end

    -- ��ͣ�˵��ص�����
    local function menuPauseCallback(sender)
        cclog("menuPauseCallback")
        if defaults:getBoolForKey(SOUND_KEY) then
            AudioEngine.playEffect(sound_1)
        end

        -- ��ͣ��ǰ���е�node
        mainLayer:pause()
        if schedulerId ~= nil then
            scheduler:unscheduleScriptEntry(schedulerId)
        end

        -- layer �ӽڵ���ͣ
        local pChildren = mainLayer:getChildren()
        for i = 1, #pChildren, 1 do
            local child = pChildren[i]
            child:pause()
        end

        -- �������˵�
        local backNormal = cc.Sprite:createWithSpriteFrameName("button.back.png")
        local backSelected = cc.Sprite:createWithSpriteFrameName("button.back-on.png")
        local backMenuItem = cc.MenuItemSprite:create(backNormal, backSelected)
        backMenuItem:registerScriptTapHandler(menuBackCallback)

        -- ������Ϸ�˵�
        local resumeNormal = cc.Sprite:createWithSpriteFrameName("button.resume.png")
        local resumeSelected = cc.Sprite:createWithSpriteFrameName("button.resume-on.png")
        local resumeMenuItem = cc.MenuItemSprite:create(resumeNormal, resumeSelected)
        resumeMenuItem:registerScriptTapHandler(menuResumeCallback)

        menu = cc.Menu:create(backMenuItem, resumeMenuItem)
        menu:alignItemsVertically()
        menu:setPosition(cc.p(size.width / 2, size.height / 2))

        mainLayer:addChild(menu, 50, 1000)
    end

        
    -- Ϊ���㴥������һ���¼�������
    touchFighterListener = cc.EventListenerTouchOneByOne:create()
    -- �����Ƿ���û�¼�����onTouchBegan��������trueʱ��û..?
    touchFighterListener:setSwallowTouches(true)
    -- EVENT_TOUCH_BEGAN �¼��ص�����
    touchFighterListener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    -- EVENT_TOUCH_MOVED �¼��ص�����
    touchFighterListener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    -- ��Ӽ�����
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchFighterListener, fighter)
    
    -- ...

    -- ����
    score = 0
    -- ����ռλ��
    scorePlaceholder = 0

    -- ��״̬����������ҵ�����ֵ
    self:updateStatusBarFighter()
    -- ��״̬������ʾ�÷�
    self:updateStatusBarScore()

    return mainLayer
end

-- �����������˵ĽӴ����
function GamePlayScene:handleFighterCollidingWithEnemy()
    
end

--�ڵ�����˵ĽӴ����
function GamePlayScene:handleBulletCollidingWithEnemy(enemy)
    
end

function GamePlayScene:onEnter()
    cclog("GamePlayScene onEnter")

    self:addChild(self:createLayer())
end

function GamePlayScene:onEnterTransitionFinish()
    cclog("GamePlayScene onEnterTransitionFinish")
    -- ��ʼ���Ƿ񲥷ű�������
    if defaults:getBoolForKey(MUSIC_KEY) then
        AudioEngine.playMusic(bg_music_2, true)
    end
end

function GamePlayScene:onExit()
    cclog("GamePlayScene onExit")
    -- ֹͣ��Ϸ����
    if schedulerId ~= nil then
        scheduler:unscheduleScriptEntry(schedulerId)
    end
    -- ע���¼�������
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if nil ~= touchFighterListener then
        eventDispatcher:removeEventListener(touchFighterListener)
    end
    if nil ~= contactListener then
        eventDispatcher:removeEventListener(contactListener)
    end

    -- ɾ��layer�ڵ��Լ����ӽڵ�
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