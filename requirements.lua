-- Helper assignments and erata
g = love.graphics
GRAVITY = 700
math.tau = math.pi * 2
COLORS = {
  RED = {r = 255, g = 0, b = 0},
  GREEN = {r = 0, g = 255, b = 0},
  BLUE = {r = 0, g = 0, b = 255},
  WHITE = {r = 255, g = 255, b = 255},
  BLACK = {r = 0, g = 0, b = 0},
  YELLOW = {r = 0, g = 255, b = 255},
  PURPLE = {r = 255, g = 0, b = 255},
}

-- The pixel grid is actually offset to the center of each pixel. So to get clean pixels drawn use 0.5 + integer increments.
g.setPoint(2.5, "rough")
math.randomseed(os.time())
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end
function pointInCircle(circle, point) return (point.x-circle.x)^2 + (point.y - circle.y)^2 < circle.radius^2 end
globalID = 0
function generateID() globalID = globalID + 1 return globalID end

-- Put any game-wide requirements in here
require 'lib/middleclass'
Stateful = require 'lib/stateful'
skiplist = require "lib/skiplist"
HC = require 'lib/HardonCollider'
inspect = require 'lib/inspect'
require 'lib/AnAL'
cron = require 'lib/cron'

require 'base'
require 'game'
require 'tower'
require 'shotgun_tower'
require 'attacker'
require 'boss'
require 'bullet'

require 'states/loading'
require 'states/main'
require 'states/menu'
require 'states/game_over'
