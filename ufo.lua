require("projectile")

function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end 
 
ufo = {
  x = love.window.getWidth(),
  y = 50,
  width = 50,
  height = 15,
  speed = 200,
  name = "ufo",
  sprite = nil,
  quad = nil,
  entities = nil,
  value = 0,
  values = {100, 200, 300},
  spawnsound = nil,
  
  new = function(self)
    result = {}
    
    love.audio.rewind(self.spawnsound)
    love.audio.play(self.spawnsound)
    
    for k, v in pairs(self) do
      result[k] = v
    end
    
    result.value = self.values[math.random(3)]
    
    return result
  end,
  
  onupdate = function(self, dt)
    self.x = self.x - (self.speed * dt)
    
    if self.x <= 0 then
      table.remove(self.entities, table_invert(self.entities)[self])
    end
  end,
  
  kill = function(self)
    self.entities.player.score = self.entities.player.score + self.value
    love.audio.rewind(enemyprojectile.explosion)
    love.audio.play(enemyprojectile.explosion)
  end
}