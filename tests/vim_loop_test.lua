local uv = vim.loop
local i = 1
local handle = uv.new_fs_event()

function on_change(err, fname, status)
  vim.nvim_command('checktime')
  print('changed '..i)
  i = i + 1

  handle:stop()
  handle:close()

  local timer = uv.new_timer()
  timer:start(1, 0, function()
    timer:stop()
    timer:close()
    handle = uv.new_fs_event()
    handle:start('test', {}, vim.schedule_wrap(on_change))
  end)
end

handle:start('test', {}, vim.schedule_wrap(on_change))
