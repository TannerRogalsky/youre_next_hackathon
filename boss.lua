Boss = class('Boss', Attacker)

function Boss:initialize(path, hp)
  Attacker.initialize(self, path, hp)

  self.radius = 15
  self.time_alive = -1
  self.path = path
  self.speed = 15
  self.worth = 5
  self.anim = newAnimation(game.preloaded_image["overlord.png"], 70, 75, 0.2, 6)
end
