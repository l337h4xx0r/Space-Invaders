require("projectile")

player = {
  x = 350,
  y = 500,
  width = 50,
  height = 20,
  speed = 150, --px/s
  sprite = nil,
  quad = nil,
  name = "player",
  firesfx = nil,
  lives = 3,
  score = 0,
  isdead = false,
  
  createprojectile = function(self)
    return projectile.new(self.x + (self.width / 2) - (projectile.width / 2), self.y - projectile.height, 500)
  end,
  
  onupdate = function(self, dt)
    
  end,
  
  kill = function(self)
    self.lives = self.lives - 1
    if self.lives == 0 then
      self.isdead = true
    end
  end
}

playerinput = {
  pce = player,
  entities = nil,
  
  handleinput = function(self, dt)
    
    if not (self.pce.x + self.pce.width >= love.window.getWidth()) then
      if keyboard.isDown("right") then
        self.pce.x = self.pce.x + (self.pce.speed * dt)
      end
    end
    
    if not (self.pce.x <= 0) then
      if keyboard.isDown("left") then
        self.pce.x = self.pce.x - (self.pce.speed * dt)
      end
    end
  end,
  
  setpce = function(self, pce)
    self.pce = pce
  end,
  
  keypressed = function(self, key)
    if key == " " and self.pce.name == "player" then
      love.audio.rewind(player.firesfx)
      love.audio.play(player.firesfx)
      table.insert(entities, self.pce:createprojectile())
    end
  end
  
}
