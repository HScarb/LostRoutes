
local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local Bullet = class("Bullet", function()
    return cc.Sprite:create()
end)

function Bullet.create(spriteFrameName)
    local sprite = Bullet.new(spriteFrameName)
    return sprite
end

function Bullet:ctor(spriteFrameName)
    
    self:setSpriteFrame(spriteFrameName)
    self:setVisible(false)
    self.velocity = Sprite_Velocity.Bullet

    local body = cc.PhysicsBody:createBox(self:getContentSize())
    body:setCategoryBitmask(0x01)           --0001
    body:setCollisionBitmask(0x02)          --0010
    body:setContactTestBitmask(0x01)        --0001
    self:setPhysicsBody(body)

    local function onNodeEvent(tag)
        if tag == "exit" then
            -- 关闭调度
            self:unscheduleUpdate()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

-- @param  fighterPos 发射炮弹的飞机的位置
-- @return nil
function Bullet:shootBulletFromFighter(fighter)

    local fighterPosX, fighterPosY = fighter:getPosition()

    self:setPosition(cc.p(fighterPosX, fighterPosY + fighter:getContentSize().height / 2))
    self:setVisible(true)

    -- update
    local function update(delta)
        
        local x, y = self:getPosition()
        self:setPosition(cc.p(x + self.velocity.x * delta, y + self.velocity.y * delta))
        x, y = self:getPosition()

        if y > size.height then
            self:setVisible(false)
            self:unscheduleUpdate()
        end
    end
    self:scheduleUpdateWithPriorityLua(update, 0)

end

return Bullet