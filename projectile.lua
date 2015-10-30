function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end

projectile = {
  x = 0,
  y = 0,
  width = 4,
  height = 13,
  speed = 0,
  sprite = nil,
  quad = nil,
  name = "projectile",
  entities = nil,
  aliendeath = nil,
  
  new = function(x, y, speed)
    local result = {}
    
    for k, v in pairs(projectile) do
      result[k] = v
    end
    
    result.x = x
    result.y = y
    result.speed = speed
    
    return result
  end,
  
  onupdate = function(self, dt)
    self.y = self.y - self.speed * dt;
    
    if self.y < 0 then
      table.remove(entities, table_invert(entities)[self])
    end
    
    for k, v in pairs(entities) do
      if type(v) == "table" and (v.name:match("spaceinvader") or v.name == "ufo") then
        if(self.x < v.x + v.width and
           self.x + self.width > v.x and
           self.y < v.y + v.height and
           self.height + self.y > v.y) then
           v:kill()
           table.remove(entities, table_invert(entities)[v])
           table.remove(entities, table_invert(entities)[self])
           love.audio.rewind(self.aliendeath)
           love.audio.play(self.aliendeath)
           break
        end
      end
    end
  end
}

enemyprojectile = {
  x = 0,
  y = 0,
  width = 4,
  height = 13,
  speed = 0,
  sprite = nil,
  quad = nil,
  name = "enemyprojectile",
  entities = nil,
  explosion = nil,
  camera = nil,
  
   new = function(x, y, speed)
    local result = {}
    
    for k, v in pairs(enemyprojectile) do
      result[k] = v
    end
    
    result.x = x
    result.y = y
    result.speed = speed
    
    return result
  end,
  
  onupdate = function(self, dt)
    self.y = self.y + self.speed * dt;
    
    
    if(self.x < entities.player.x + entities.player.width and
      self.x + self.width > entities.player.x and
      self.y < entities.player.y + entities.player.height and
      self.height + self.y > entities.player.y) then
      
      love.audio.rewind(self.explosion)
      love.audio.play(self.explosion)
      entities.player:kill()
      table.remove(entities, table_invert(entities)[self])
      camera:shake()
      
    end
  end
}
