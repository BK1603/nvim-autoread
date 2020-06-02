local uv = vim.loop
--[[
  Create a file watcher, each watcher is identified by the name of the file that it 
  watches. We can use a lua table to store all watchers indexed by their filenames 
  so that we can close the required watcher during the callback to on_change to 
  debounce the watcher.
--]]

local Watcher = {}
local WatcherList = {}

function Watcher:new(fname)
  assert(fname ~= '', 'Watcher.new: Error: fname is an empty string')
  w = {fname = fname, handle = {}}
  setmetatable(w, self)
  self.__index = self
  WatcherList[fname] = w
  for key, val in pairs(WatcherList) do
    print(key, val)
  end
  return w
end

function Watcher:start()
  assert(self.fname ~= '', 'Watcher.start: Error: no file to watch')
  print(WatcherList[self.fname])
  -- get a new handle
  self.handle = uv.new_fs_event()
  -- get full path name here
  local fullname = vim.api.nvim_call_function('fnamemodify', {self.fname, ':p'})
  self.handle:start(fullname, {}, on_change)
  print(self.handle:getpath())
end

function Watcher:stop()
  assert(self.fname ~= '', 'Watcher.stop: Error: no file being watched')
  assert(self.handle ~= {}, 'Watcher.stop: Error: no handle watching the file')
  self.handle:stop()
  -- close the handle altogether, for windows.
  self.handle:close()
end

function on_change(err, fname, events)
  print(err, fname, events)
end

function watch_file(fname)
  local w = Watcher:new(fname)
  w:start()
end

function stop_watch(fname)
  WatcherList[fname]:stop()
  WatcherList[fname] = nil
end

vim.api.nvim_command("command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))")
vim.api.nvim_command("command! -nargs=1 Stop call luaeval('stop_watch(_A)', expand('<args>'))")
