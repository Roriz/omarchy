-- Model the placement regression: explicit outputs occupy their coordinates;
-- automatic outputs are placed after them. Merely logging hl.monitor misses it.
local panel = { name = "eDP-1", serial = "", description = "", width = 1920, height = 1080,
  scale = 2, refresh_rate = 60, transform = 0, x = tonumber(arg[2]), y = tonumber(arg[3]) }
local external = { name = "HDMI-A-1", serial = "HX5X721467", description = "", width = 1920,
  height = 1080, scale = 1, refresh_rate = 60, transform = 0, x = 0, y = 0 }
local monitors = { external, panel }

for reload = 1, 3 do
  local rules = {}
  hl = {
    get_monitors = function() return monitors end,
    get_monitor = function(name)
      for _, monitor in ipairs(monitors) do
        if monitor.name == name then return monitor end
      end
    end,
    monitor = function(rule) rules[rule.output] = rule end,
  }
  local file = io.open(arg[1])
  if file then
    file:close()
    dofile(arg[1])
  end
  local right = 0
  for _, monitor in ipairs(monitors) do
    local rule = rules[monitor.name]
    if rule then
      local x, y = rule.position:match("^(-?%d+)x(-?%d+)$")
      assert(x and y, "saved monitor positions must be explicit")
      monitor.x, monitor.y = tonumber(x), tonumber(y)
      monitor.scale = rule.scale
      right = math.max(right, monitor.x + monitor.width / monitor.scale)
    end
  end
  for _, monitor in ipairs(monitors) do
    if not rules[monitor.name] then
      monitor.x, monitor.y = right, 0
      right = right + monitor.width / monitor.scale
    end
  end
  assert(external.x == 0 and external.y == 0, "reload " .. reload .. " displaced the automatic external")
  assert(panel.x == tonumber(arg[2]) and panel.y == tonumber(arg[3]), "reload " .. reload .. " displaced the panel")
end
