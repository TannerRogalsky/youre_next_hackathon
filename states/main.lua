local Main = Game:addState('Main')
Game.static.TOWER_HASH = {}
Game.static.TOWER_HASH["1"] = Tower
Game.static.TOWER_HASH["2"] = ShotgunTower

function Main:enteredState()
  self.collider = HC(50, self.on_start_collide, self.on_stop_collide)
  self.towers = {}
  self.bullets = {}
  self.attackers = {}

  self.bank = 10
  self.attacker_hp = 10
  self.active_tower = Game.TOWER_HASH["1"]

  cron.every(2, function()
    local new_attacker = Attacker:new(Attacker.PATHS[2], game.attacker_hp)
    table.insert(self.attackers, new_attacker)
    new_attacker.index = #self.attackers
  end)
  cron.after(15, function()
    cron.every(2, function()
      local new_attacker = Attacker:new(Attacker.PATHS[1], game.attacker_hp)
      table.insert(self.attackers, new_attacker)
      new_attacker.index = #self.attackers
    end)
  end)
  cron.after(30, function()
    cron.every(2, function()
      local new_attacker = Attacker:new(Attacker.PATHS[3], game.attacker_hp)
      table.insert(self.attackers, new_attacker)
      new_attacker.index = #self.attackers
    end)
  end)
  cron.every(25, function() game.attacker_hp = game.attacker_hp + 5 end)

  self:create_bounds()
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
  g.setColor(255,255,255)
  g.print("Bank: " .. self.bank, 0, 0)
  g.print("Tower: " .. self.active_tower.name, 100, 0)

  for id,tower in pairs(self.towers) do
    tower:render()
  end

  for id,bullets in pairs(self.bullets) do
    bullets:render()
  end

  for i,attackers in ipairs(self.attackers) do
    attackers:render()
  end

  g.setColor(255,255,255)
  g.print("Bank: " .. self.bank, 0, 0)
  g.print("Tower: " .. self.active_tower.name, 100, 0)

  camera:unset()
end

function Main:mousepressed(x, y, button)
  if self.bank >= Tower.COST then

    local on_terrain = false
    for _,terrain in ipairs(self.terrain) do
      if terrain:contains(x,y) then
        on_terrain = true
        break
      end
    end

    if on_terrain then
      local new_tower = self.active_tower:new(x, y)
      self.towers[new_tower.id] = new_tower
    end
  end
end

function Main:mousereleased(x, y, button)
end

function Main:keypressed(key, unicode)
  if Game.TOWER_HASH[key] then
    self.active_tower = Game.TOWER_HASH[key]
  end
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

function Main:create_bounds(padding, collision_callback)
  padding = padding or 50
  local boundary_collision = collision_callback or function(self, dt, shape_one, shape_two, mtv_x, mtv_y)
    -- self is the boundary object (not the physics object)
    local other_object = shape_two.parent

    if instanceOf(Bullet, other_object) then
      game.collider:remove(shape_two)
      game.bullets[other_object.id] = nil
    end
  end

  local bound = self.collider:addRectangle(-padding, -padding, g.getWidth() + padding * 2, 50)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision

  bound = self.collider:addRectangle(g.getWidth(), -padding, 50, g.getHeight() + padding * 2)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision

  bound = self.collider:addRectangle(-padding, g.getHeight(), g.getWidth() + padding * 2, 50)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision

  bound = self.collider:addRectangle(-padding, -padding, 50, g.getHeight() + padding * 2)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision
end

return Main
