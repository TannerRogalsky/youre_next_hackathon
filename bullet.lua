Bullet = class('Bullet', Base)

function Bullet:initialize(origin, angle, damage)
  Base.initialize(self)

  self.pos = origin
  self.pos.incr = function(self, k, v) self[k] = self[k] + v end
  self.radius = 3
  self.angle = angle
  self.speed = 15
  self.damage = damage
  self.image = game.preloaded_image["bullet.png"]

  self._physics_body = game.collider:addPoint(self.pos.x, self.pos.y)
  self._physics_body.parent = self
  game.collider:addToGroup("towers_and_bullets", self._physics_body)
end

function Bullet:update(dt)
  local x = self.speed * math.cos(self.angle)
  local y = self.speed * math.sin(self.angle)
  self:move(x,y)
end

function Bullet:render()
  g.setColor(255,255,255)
  g.draw(self.image, self.pos.x - 9, self.pos.y - 9)
  -- g.setColor(0,255,0)
  -- g.circle("fill", self.pos.x, self.pos.y, self.radius)

  -- g.setColor(0,0,0,255)
  -- local x = self.pos.x + self.radius * math.cos(self.angle)
  -- local y = self.pos.y + self.radius * math.sin(self.angle)
  -- g.line(self.pos.x, self.pos.y, x, y)
end

function Bullet:move(x, y)
  self.pos:incr('x', x)
  self.pos:incr('y', y)
  self._physics_body:move(x,y)
end
