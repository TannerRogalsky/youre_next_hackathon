local Main = Game:addState('Main')

function Main:enteredState()
  self.collider = HC(50, self.on_start_collide, self.on_stop_collide)
  self.towers = {}
  self.bullets = {}
  self.attackers = {}

  cron.every(2, function()
    local new_attacker = Attacker:new(Attacker.PATHS[1], 10)
    table.insert(self.attackers, new_attacker)
    new_attacker.index = #self.attackers
  end)
end

function Main:update(dt)
  cron.update(dt)
  self.collider:update(dt)

  for id,tower in pairs(self.towers) do
    tower:update(dt)
  end

  for id,bullets in pairs(self.bullets) do
    bullets:update(dt)
  end

  for id,attackers in pairs(self.attackers) do
    attackers:update(dt)
  end
end

function Main:render()
  camera:set()

  for id,tower in pairs(self.towers) do
    tower:render()
  end

  for id,bullets in pairs(self.bullets) do
    bullets:render()
  end

  for i,attackers in ipairs(self.attackers) do
    attackers:render()
  end

  camera:unset()
end

function Main:mousepressed(x, y, button)
  local new_tower = Tower:new(x, y)
  self.towers[new_tower.id] = new_tower
end

function Main:mousereleased(x, y, button)
end

function Main:keypressed(key, unicode)
end

function Main:keyreleased(key, unicode)
end

function Main:joystickpressed(joystick, button)
  print(joystick, button)
end

function Main:joystickreleased(joystick, button)
  print(joystick, button)
end

function Main:focus(has_focus)
end

function Main.on_start_collide(dt, shape_one, shape_two, mtv_x, mtv_y)
  if game.over then return end

  local object_one, object_two = shape_one.parent, shape_two.parent

  -- print(object_one, object_two)

  if type(object_one.on_collide) == "function" then
    object_one:on_collide(dt, shape_one, shape_two, mtv_x, mtv_y)
  end

  if type(object_two.on_collide) == "function" then
    object_two:on_collide(dt, shape_two, shape_one, -mtv_x, -mtv_y)
  end
end

function Main.on_stop_collide(dt, shape_one, shape_two)
  -- print(tostring(shape_one.parent) .. " stopped colliding with " .. tostring(shape_two.parent))
end


return Main
