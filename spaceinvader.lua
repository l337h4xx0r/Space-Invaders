
require("projectile")

function copyof(class)
  local result = {}
  
  for k, v in pairs(class) do
    result[k] = v
  end
  
  return result
end

spaceinvader = {
  x = 0,
  y = 0,
  rx = 0,
  ry = 0,
  width = 27,
  height = 27,
  sprite = nil,
  quad = nil,
  name = "spaceinvader",
  block = nil,
  position = 0,
  value = 10,
  entities = nil,
  
  launchProjectile = function(self)
    table.insert(self.entities, enemyprojectile.new(self.x + self.width / 2, self.y + self.height, 300))
  end,
  
  onupdate = function(self, dt)
    self.x = block.x + self.rx
    self.y = block.y + self.ry
    
    if self.x - self.width <= 0 and self.block.check then
      self.block.increaseheight = true
      self.block.speed = -self.block.speed
      self.block.check = false
    elseif self.x + self.width * 2 >= love.window.getWidth() and self.block.check then
      self.block.increaseheight = true
      self.block.speed = -self.block.speed
      self.block.check = false
    end
    
    if self.block.update then
      if self.position == 0 then
        self.quad = love.graphics.newQuad(0, self.height, self.width, self.height, self.sprite:getWidth(), self.sprite:getHeight())
        self.position = 1
      else
        self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.sprite:getWidth(), self.sprite:getHeight())
        self.position = 0
      end
    end
    
    if math.random(10000) == 10000 then
      self:launchProjectile()
    end
    
    if self.y >= love.window.getHeight() then
      entities.player:kill()
    end
  end,
  
  new = function(self)
    return copyof(self)
  end,
  
  kill = function(self)
    if not (self.block.targettime <= 0.05)  then
      block.targettime = block.targettime - 0.027
    end
    self.entities.player.score = self.entities.player.score + self.value
    self.block.amount = self.block.amount - 1
  end
  
}

spaceinvader2 = copyof(spaceinvader)
spaceinvader3 = copyof(spaceinvader)

spaceinvader2.name = "spaceinvader2"
spaceinvader3.name = "spaceinvader3"

spaceinvader2.value = 20
spaceinvader3.value = 30


block = { --represents the group of space invaders, instead of moving them individually, it makes more sense and potentially saves cpu cycles to move them as a block
  x = 50,
  y = 50,
  width = 600,
  height = 300,
  entities = nil,
  time = 0,
  targettime = 1.5,
  speed = spaceinvader.width,
  increaseheight = false,
  check = true,
  update = false,
  amount = 0,
  resets = 0,
  
  populate = function(self)
    local row = 1
    local column = 1
    local columns = 22
    local rows = 5
    
    local invader = true
    
    for row = 1, rows do
      for column = 1, columns do
        if invader then
          local new = nil
          
          if row == 1 then
            new = spaceinvader3:new()
          elseif row == 2 or row ==3 then
            new = spaceinvader2:new()
          else
            new = spaceinvader:new()
          end
          
          new.block = self
          new.rx = column * (width / spaceinvader.width)
          new.ry = row * spaceinvader.height
          table.insert(entities, new)
          self.amount = self.amount + 1
        end
        invader = not invader
      end
    end
  end,
  
  onupdate = function(self, dt)
    self.time = self.time + dt
    self.update = false
    if self.time >= self.targettime then
      if self.increaseheight then
        self.y = self.y + (spaceinvader.height / 2)
        self.increaseheight = false
        self.check = false
      else
        self.x = self.x + self.speed
        self.check = true
      end
      self.update = true
      
      self.time = 0
    end
    if self.amount <= 0 then
      self.x = 50
      self.y = 50
      self.amount = 0
      self:populate()
      self.targettime = 1.5 - (0.03 * self.resets)
      self.resets = self.resets + 1
    end
  end
}
