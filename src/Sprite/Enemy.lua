
local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local Enemy = class("Enemy",function()
    return cc.Sprite:create()
end)

function Enemy.create(EnemyType)
    local sprite = Enemy.new(EnemyType)
    return sprite
end

function Enemy:ctor(enemyType)
    
    -- 精灵帧
    local enemyFram
end