ShotgunTower = class('ShotgunTower', Tower)

function ShotgunTower:initialize(x, y)
  Tower.initialize(self, x, y)

  self.color = {r = 255, g = 255, b = 0}
  self.spread = 20
  self.damage = 3

  for job,active in pairs(self.jobs) do
    cron.cancel(job)
  end

  local new_job = cron.every(4, function()
    self:shoot(self.angle)
    self:shoot(self.angle)
    self:shoot(self.angle)
    self:shoot(self.angle)
  end)
  self.jobs[new_job] = true
end
