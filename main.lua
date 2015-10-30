# LÖVE -- for reference so I can c/p it with the umlaut

--modules
require("player")
require("entities")
require("events")
require("spaceinvader")
utf8 = require("utf8")

--variables
g = love.graphics --shortcut
keyboard = love.keyboard

width, height, display, fsaa = 800, 600, 1, 4
fs, resizeable, borderless, vsync = false, false, false, false
isingame = true

background = nil
backgroundquad = nil

shouldgenerate = true

name = ""
active = fals
leaderboard = false

leaderboardtext = ""

camera = {
  xoffset = 0,
  yoffset = 0,
  xmag = 10, --x magnitude
  ymag = 10, --y magnitude
  speed = 30,
  isshaking = false,
  time = 0,
  shaketime = 0.5,
  
  shake = function(self)
    self.isshaking = true
  end,
  
  onupdate = function(self, dt)
    if self.isshaking then
      self.time = self.time + dt
      if self.time >= self.shaketime then
        self.isshaking = false
        self.time = 0
      end
      self.xoffset = self.xmag * math.sin(self.time * self.speed * 2)
      self.yoffset = self.ymag * math.sin(self.time * self.speed)
    end
  end
}

function love.textinput(text)
  if text ~= " " and text ~= "\n" and text ~=":" and active then
    name = name .. text
  end
end

function submitscore()
  local scores = io.open("scores.dat", "a")
  if name == "" then
    name = "unnamed"
  end
  
  scores:write(name .. ":" .. player.score .."\n")
  scores:close()
end

function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end

function esc(x)
  return (x:gsub('%%', '%%%%')
           :gsub('%^', '%%%^')
           :gsub('%$', '%%%$')
           :gsub('%(', '%%%(')
           :gsub('%)', '%%%)')
           :gsub('%.', '%%%.')
           :gsub('%[', '%%%[')
           :gsub('%]', '%%%]')
           :gsub('%*', '%%%*')
           :gsub('%+', '%%%+')
           :gsub('%-', '%%%-')
           :gsub('%?', '%%%?'))
end

function spairs(t, order) --stolen from SO, thanks to user Michal Kottman
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function displayleaderboard()
  leaderboard = true
  local scores = io.open("scores.dat", "r")
  local scoretable = {}
  
  repeat
    local line = scores:read()
    if line ~= nil then
      local one, two = line:match("([^:]+):([^:]+)")
      if one == nil then
        one = "unnamed"
      end
      
      local i = 1
      
      while scoretable[one] do
        one = one .. ":" --:'s can't be part of the name anyway, we will replace these with empty strings when it comes to displaying them
        i = i + 1
      end
      scoretable[one] = tonumber(two)
    end
  until not line
  
  local f = 0
  
  for k, v in spairs(scoretable, function(t,a,b) return t[b] < t[a] end) do
    if f >= 6 then
      break
    else
      f = f + 1
      leaderboardtext = leaderboardtext .. f .. "\t" .. k .. "\t" .. v .. "\n\n"
    end
  end
end

nameinput = {
  keypressed = function(self, key)
    if key == "backspace" then
      local byteoffset = utf8.offset(name, -1)

      if byteoffset then
        name = string.sub(name, 1, byteoffset - 1)
      end
    elseif key == "return" then
      submitscore()
      displayleaderboard()
    end
  end
}

--functions

function loadsprt(entity)
    entity.sprite = g.newImage(entity.name .. "sprt.png")
    entity.quad = g.newQuad(0, 0, entity.width, entity.height, entity.sprite:getWidth(), entity.sprite:getHeight())
end

function love.load()
  love.window.setTitle("First LÖVE2D Game: Space Invaders")
  
  love.window.setMode(width, height, {fullscreen = fs, fullscreentype = "normal", vsync = vsync, fsaa = fsaa, resizable = resizeable, borderless = borderless,
      centered = true, display = display, minwidth = 200, minheight = 150, highdpi = false, srgb = false, x = nil, y = nil})
  
  loadsprt(ufo)
  loadsprt(player)
  loadsprt(projectile)
  loadsprt(spaceinvader)
  loadsprt(spaceinvader2)
  loadsprt(spaceinvader3)
  loadsprt(enemyprojectile)
  
  background = g.newImage("background.png")
  backgroundquad = g.newQuad(0, 0, width,height, background:getWidth(), background:getHeight())
  
  enemyprojectile.explosion = love.audio.newSource("explosion.wav", "static")
  projectile.aliendeath = love.audio.newSource("aliendeath.wav", "static")
  ufo.spawnsound = love.audio.newSource("ufospawn.wav", "static")
  player.firesfx = love.audio.newSource("fire.wav", "static")
  gamemusic = love.audio.newSource("music.ogg")
  gamemusic:setLooping(true)
  gamemusic:setVolume(0.5)
  player.firesfx:setVolume(0.7)
  projectile.aliendeath:setVolume(0.7)
  
  playerinput.entities = entities
  projectile.entities = entities
  block.entities = entities
  spaceinvader.entities = entities
  spaceinvader2.entities = entities
  spaceinvader3.entities = entities
  enemyprojectile.entities = entities
  ufo.entities = entities
  
  enemyprojectile.camera = camera
  
  entities.player = player
  
  table.insert(entities, player)
  table.insert(keypressrecv, playerinput)
  
  love.audio.play(gamemusic)
  
  local font = g.newFont("ethnocentric_rg.ttf", 12)
  
  g.setFont(font)
  
  math.randomseed(os.time())
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(math.floor(camera.xoffset), math.floor(camera.yoffset))

  if isingame and not player.isdead then
    g.draw(background)
    for k, v in pairs(entities) do
      if type(v) == "table" then
        g.draw(v.sprite, v.quad, v.x, v.y)
      end
    end
    g.print("Score: " .. player.score .."\nLives: " .. player.lives, 20, 20)
  elseif leaderboard then
    g.printf("High Scores\n\n\n" .. leaderboardtext:gsub(":+", ""), 0, 100, 800, 'center')
  elseif player.isdead then
    g.printf("Game Over\nEnter your name: " .. name, 0, love.window.getHeight() / 2, 800, 'center')
    g.print("Score: " .. player.score .."\nLives: " .. player.lives, 20, 20)
  end
  
  love.graphics.pop()
end

function love.update(dt)
  if isingame and not player.isdead then
    if shouldgenerate then
      block:populate()
      shouldgenerate = false
    end
    playerinput:handleinput(dt)
    entities:onupdate(dt)
    block:onupdate(dt)
    camera:onupdate(dt)
  elseif player.isdead then
    if not active then
      active = true
      table.remove(keypressrecv, 1)
      table.insert(keypressrecv, nameinput)
    end
  end
end
