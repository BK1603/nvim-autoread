local uv = vim.loop
--[[
  Create a file watcher, each watcher is identified by the name of the file that it 
  watches. We can use a lua table to store all watchers indexed by their filenames 
  so that we can close the required watcher during the callback to on_change to 
  debounce the watcher.
--]]

local Watcher = {
  fname = '',
  ffname = '',
  handle = nil
}
local WatcherList = {}

function Watcher:new(fname)
  assert(fname ~= '', 'Watcher.new: Error: fname is an empty string')
  -- get full path name for the file
  local ffname = vim.api.nvim_call_function('fnamemodify', {fname, ':p'})
  w = {fname = fname, ffname = ffname, handle = nil}
  setmetatable(w, self)
  self.__index = self
  WatcherList[fname] = w
  return w
end

function Watcher:start()
  assert(self.fname ~= '', 'Watcher.start: Error: no file to watch')
  assert(self.ffname ~= '', 'Watcher.start: Error: full path for file not available')
  -- get a new handle
  self.handle = uv.new_fs_event()
  self.handle:start(self.ffname, {}, vim.schedule_wrap(self.on_change))
end

function Watcher:stop()
  assert(self.fname ~= '', 'Watcher.stop: Error: no file being watched')
  assert(self.handle ~= nil, 'Watcher.stop: Error: no handle watching the file')
  self.handle:stop()
  -- close the handle altogether, for windows.
  self.handle:close()
end

function Watcher.on_change(err, fname, events)
  if events.change then
    print(fname..' changed')
  end
  WatcherList[fname]:stop()
  WatcherList[fname]:start()
end

function Watcher.watch(fname)
  local w = Watcher:new(fname)
  w:start()
end

function Watcher.stop(fname)
  if WatcherList[fname] == nil then
    print('No watcher running on '..fname)
    return
  end
  WatcherList[fname]:stop()
  WatcherList[fname] = nil
end

return Watcher
