local Main = Game:addState('Main')
Game.static.TOWER_HASH = {}
Game.static.TOWER_HASH["1"] = Tower
Game.static.TOWER_HASH["2"] = ShotgunTower

function Main:enteredState()
  self.collider = HC(50, self.on_start_collide, self.on_stop_collide)
  self.towers = {}
  self.bullets = {}
  self.attackers = {}
  self.terrain = {}

  self.metal = self.preloaded_image["metal1.jpg"]
  self.background = self.preloaded_image["stars2.jpg"]
  self.background:setWrap("repeat", "repeat")
  local ww,wh,iw,ih = g.getWidth(), g.getHeight(), self.background:getWidth(), self.background:getHeight()
  self.bg_quad = love.graphics.newQuad(0, 0, ww, wh, iw, ih)

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

  self:create_bounds(50)
  self:create_terrain()
end

function Main:update(dt)
  if game.over then return end
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
  g.drawq(self.background, self.bg_quad, 0, 0)

  for _,terrain in ipairs(self.terrain) do
    terrain:render()
  end

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

  if game.over then
      g.setColor(0,0,0,255/2)
      g.rectangle('fill', 0,0,g.getWidth(), g.getHeight())
      g.setColor(255,255,255,255)
      local text = "You lost."
      local offset = self.font:getWidth(text) / 2
      g.print(text, g.getWidth() / 2 - offset, g.getHeight() / 2)
  end

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

    local collides_with_other = false
    for id,tower in pairs(self.towers) do
      local dist = math.sqrt(math.pow(tower.pos.x - x, 2) + math.pow(tower.pos.y - y, 2))
      if dist > 25 + 25 then
        collides_with_other = false
      else
        collides_with_other = true
        break
      end
    end

    if on_terrain and not collides_with_other then
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
  padding = padding or 0
  local boundary_collision = collision_callback or function(self, dt, shape_one, shape_two, mtv_x, mtv_y)
    -- self is the boundary object (not the physics object)
    local other_object = shape_two.parent

    if instanceOf(Bullet, other_object) then
      game.collider:remove(shape_two)
      game.bullets[other_object.id] = nil
    end
  end

  local bound = self.collider:addRectangle(-padding, -padding - 50, g.getWidth() + padding * 2 + 100, 50)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision

  bound = self.collider:addRectangle(g.getWidth() + padding, -padding, 50, g.getHeight() + padding * 2)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision

  bound = self.collider:addRectangle(-padding, g.getHeight() + padding, g.getWidth() + padding * 2  + 100, 50)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision

  bound = self.collider:addRectangle(-padding - 50, -padding, 50, g.getHeight() + padding * 2)
  bound.parent = {bound = true}
  self.collider:setPassive(bound)
  bound.parent.on_collide = boundary_collision
end

function Main:create_terrain()
  local w,h = g.getWidth(), g.getHeight()
  local terrain

  local terrain_render = function(self)
    g.setColor(255, 255, 255)
    love.graphics.draw(self.texture, 0, 0)
    g.setColor(0, 0, 0, 255)
    self:draw("line")
  end

  terrain = self.collider:addPolygon(20,0, 650,0, 325,300)
  self.collider:setGhost(terrain)
  local x1,y1, x2,y2 = terrain:bbox()
  terrain.texture = self.newTexturedPolygon({terrain._polygon:unpack()}, self.metal, x2, y2)
  terrain.render = terrain_render
  table.insert(self.terrain, terrain)
  terrain = self.collider:addPolygon(20,h, 650,h, 325,h-300)
  self.collider:setGhost(terrain)
  x1,y1, x2,y2 = terrain:bbox()
  terrain.texture = self.newTexturedPolygon({terrain._polygon:unpack()}, self.metal, x2, y2)
  terrain.render = terrain_render
  table.insert(self.terrain, terrain)
end

function Main.newTexturedPolygon(vertices, img, max_x, max_y)
  -- We want our images to tile
  img:setWrap("repeat", "repeat")

  -- We need a quad so the img is repeated
  -- The quad width/height should be the max x/y of the poly
  local quad = love.graphics.newQuad(0, 0, max_x, max_y, img:getWidth(), img:getHeight())

  -- Set up and store our clipped canvas once as it's expensive
  local canvas = love.graphics.newCanvas()

  love.graphics.setCanvas(canvas)

  -- Our clipping function, we want to render within a polygon shape
  local myStencilFunction = function()
    love.graphics.polygon("fill", unpack(vertices))
  end
  love.graphics.setStencil(myStencilFunction)

  -- Setting to premultiplied means that pixels just get overlaid ignoring
  -- their alpha values. Then when we render this canvas object itself, we
  -- will use the alpha of the canvas itself
  love.graphics.setBlendMode("premultiplied")

  -- Draw the repeating image within the quad
  love.graphics.drawq(img, quad, 0, 0)

  -- Reset everything back to normal
  love.graphics.setBlendMode("alpha")
  love.graphics.setStencil()
  love.graphics.setCanvas()

  return canvas
end

return Main
