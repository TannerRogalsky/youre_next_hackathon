Attacker = class('Attacker', Base)
Attacker.static.PATHS = {
  [1] = function(self, dt) return dt * self.speed, dt * self.speed end,
  [2] = function(self, dt)
    local x, y
    x = dt * self.speed
    y = math.sin(dt) * (self.speed * 2) + g.getHeight() / 2
    return x, y
  end,
  [3] = function(self, dt) return dt * self.speed, g.getHeight() - dt * self.speed end,
}

function Attacker:initialize(path, hp)
  Base.initialize(self)

  self.pos = {x = 0, y = 0}
  self.pos.incr = function(self, k, v) self[k] = self[k] + v end

  self.radius = 15
  self.time_alive = -1
  self.path = path
  self.speed = 20
  self.hp = hp
  self.worth = 1

  self._physics_body = game.collider:addCircle(self.pos.x, self.pos.y, self.radius)
  self._physics_body.parent = self
  game.collider:addToGroup("attackers", self._physics_body)
end

function Attacker:update(dt)
  self.time_alive = self.time_alive + dt
  local new_x, new_y = self:path(self.time_alive)
  self:move_to(new_x, new_y)
end

function Attacker:render()
  g.setColor(0,255,255)
  g.circle("fill", self.pos.x, self.pos.y, self.radius)

  g.setColor(0,0,0,255)
  g.print(self.hp, self.pos.x - 10, self.pos.y - 10)

  -- g.setColor(0,0,0,255)
  -- local x = self.pos.x + self.radius * math.cos(self.angle)
  -- local y = self.pos.y + self.radius * math.sin(self.angle)
  -- g.line(self.pos.x, self.pos.y, x, y)
end

function Attacker:move(x, y)
  self.pos:incr('x', x)
  self.pos:incr('y', y)
  self._physics_body:move(x,y)
end

function Attacker:move_to(x, y)
  self.pos = {x = x, y = y}
  self._physics_body:moveTo(x,y)
end

function Attacker:on_collide(dt, shape_one, shape_two, mtv_x, mtv_y)
  local other_object = shape_two.parent

  if instanceOf(Bullet, other_object) then
    game.collider:remove(shape_two)
    game.bullets[other_object.id] = nil
    self.hp = self.hp - other_object.damage
    if self.hp <= 0 then
      game.bank = game.bank + self.worth
      game.collider:remove(shape_one)

      -- stupid not being able to use a hash because we need to
      for index, attacker in ipairs(game.attackers) do
        if self == attacker then
          table.remove(game.attackers, index)
          break
        end
      end
    end
  end
end
