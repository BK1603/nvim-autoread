local uv = require('luv')
local i = 1
local handle = uv.new_fs_event()

function on_change(err, fname, status)
  local stat = uv.fs_stat(fname)
  if stat ~= fail then
    print('changed '..i)
    i = i + 1
  else
    print('renamed')
  end
  handle:stop()
  handle:close()

  local timer = uv.new_timer()
  timer:start(1, 0, function()
    timer:stop()
    timer:close()
    handle = uv.new_fs_event()
    handle:start('test', {}, on_change)
  end)
end

handle:start('test', {}, on_change)

uv.run()
