
keypressrecv = {
  
}

function love.keypressed(key)
  for k, v in pairs(keypressrecv) do
    v:keypressed(key)
  end
end