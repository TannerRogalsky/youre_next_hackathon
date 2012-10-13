Tower = class('Tower', Base)
Tower.static.COST = 5

function Tower:initialize(x, y)
  Base.initialize(self)

  self.pos = {x = x, y = y}
  self.spread = 0
  self.radius = 25
  self.angle = 0
  self.damage = 5
  self.color = {r = 255, g = 255, b = 255}
  self.jobs = {}

  self._physics_body = game.collider:addCircle(self.pos.x, self.pos.y, self.radius)
  self._physics_body.parent = self
  game.collider:addToGroup("towers_and_bullets", self._physics_body)

  local new_job = cron.every(2, function()
    self:shoot(self.angle)
  end)
  self.jobs[new_job] = true

  game.bank = game.bank - Tower.COST
end

function Tower:update(dt)
  local target = game.attackers[1]
  if target == nil then return end
  self.angle = math.atan2(target.pos.y - self.pos.y, target.pos.x - self.pos.x)
end

function Tower:render()
  g.setColor(self.color.r, self.color.g, self.color.b)
  g.circle("fill", self.pos.x, self.pos.y, self.radius)

  g.setColor(0,0,0,255)
  local x = self.pos.x + self.radius * math.cos(self.angle)
  local y = self.pos.y + self.radius * math.sin(self.angle)
  g.line(self.pos.x, self.pos.y, x, y)
end

function Tower:shoot(angle)
  local spread = math.random(-self.spread, self.spread)
  local angle_of_attack = angle + math.rad(spread)
  local x = self.pos.x + self.radius * math.cos(angle_of_attack)
  local y = self.pos.y + self.radius * math.sin(angle_of_attack)
  local bullet = Bullet:new({x = x, y = y}, angle_of_attack, self.damage)
  game.bullets[bullet.id] = bullet
end

function Tower:on_collide(dt, shape_one, shape_two, mtv_x, mtv_y)
  local other_object = shape_two.parent

  if instanceOf(Attacker, other_object) then
    game.collider:remove(shape_one)
    game.towers[self.id] = nil
    for job,active in pairs(self.jobs) do
      cron.cancel(job)
    end
  end
end
