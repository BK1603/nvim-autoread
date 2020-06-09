local uv = require('luv')
local i = 1
local handle = uv.new_fs_event()

function on_change(err, fname, status)
  print('changed '..i)
  i = i + 1

  handle:stop()
  handle:close()
  local timer = uv.new_timer()
  timer:start(0, 0, function()
    timer:stop()
    timer:close()
    handle = uv.new_fs_event()
    handle:start('test', {}, on_change)
  end)
end

io.open('log_luv', 'w'):close()
handle:start('test', {}, on_change)

uv.run()
