require("ufo")

entities = {
  player = nil,
  
  onupdate = function(self, dt)
    if math.random(math.floor(30 / dt)) == math.floor(30 / dt) then
      table.insert(self, ufo:new())
    end
    
    for k, v in pairs(self) do
      if type(v) == "table" then
        v:onupdate(dt)
      end
    end
  end
}