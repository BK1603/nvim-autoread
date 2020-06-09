--[[
  Create a file watcher, each watcher is identified by the name of the file that it 
  watches. We can use a lua table to store all watchers indexed by their filenames 
  so that we can close the required watcher during the callback to on_change to 
  debounce the watcher.
--]]

local uv = vim.loop
local os = require('os')
local i = 1

local Watcher = {
  fname = '',
  ffname = '',
  handle = nil,
-- Variable to restrict response to multiple notifications
  responded = false
}
local WatcherList = {}

function Watcher:new(fname)
  assert(fname ~= '', 'Watcher.new: Error: fname is an empty string')
  -- get full path name for the file
  local ffname = vim.api.nvim_call_function('fnamemodify', {fname, ':p'})
  w = {fname = fname, ffname = ffname, handle = nil}
  setmetatable(w, self)
  self.__index = self
  return w
end

function Watcher:start()
  assert(self.fname ~= '', 'Watcher.start: Error: no file to watch')
  assert(self.ffname ~= '', 'Watcher.start: Error: full path for file not available')
  -- get a new handle
  self.handle = uv.new_fs_event()
  self.handle:start(self.ffname, {}, vim.schedule_wrap(self.on_change))
  self.responded = false
end

function Watcher:stop()
  assert(self.fname ~= '', 'Watcher.stop: Error: no file being watched')
  assert(self.handle ~= nil, 'Watcher.stop: Error: no handle watching the file')
  self.handle:stop()
  -- close the handle altogether, for windows.
  self.handle:close()
end

function Watcher.on_change(err, fname, events)
  if WatcherList[fname].responded ~= true then
    if events.change then
       --vim.api.nvim_command('call PromptReload()')
       --vim.api.nvim_command('checktime')

       print('changed '..i)
       i = i + 1

       WatcherList[fname].responded = true
    end
  -- sleep for a bit, to ignore multiple notifications from a single change
  -- caused by various editors. (Like (neo)vim :P)
    local timer = uv.new_timer()
    timer:start(1, 0, function()
      timer:stop()
      timer:close()
      WatcherList[fname]:stop()
      WatcherList[fname]:start()
    end)
  end
end

function Watcher.watch(fname)
  -- since we can only get file name from callback, use only the file
  -- name for storing in table. (Without the rest of the path.)
  local f = vim.api.nvim_call_function('fnamemodify', {fname, ':t'})

  -- if a watcher already exists, do nothing.
  if WatcherList[f] ~= nil then
    return
  end

  -- create a new watcher and it to the watcher list.
  local w = Watcher:new(fname)
  WatcherList[f] = w
  w:start()
end

function Watcher.stop_watch(fname)
  -- Do nothing if we opened a doc file. For some reason doc files never
  -- trigger any event that could start a watcher, and trigger both BufDelete
  -- and BufUnload. This causes us to close watchers that weren't even there
  -- in the first place. We ignore help files here.
  -- TODO: Is there way of getting buftype from the nvim api?
  if starts_with(fname, '/usr/local/share/nvim/runtime/doc') then
    return
  end
  -- if it is a help buffer, do nothing
  -- get the name that must have been used as the key for the table.
  local f = vim.api.nvim_call_function('fnamemodify', {fname, ':t'})

  -- if there is no watcher, print out an error and exit
  if WatcherList[f] == nil then
    print('No watcher running on '..fname)
    return
  end

  -- stop and close the watcher handle, and set watcher to nil
  WatcherList[f]:stop()
  WatcherList[f] = nil
end

function starts_with(str, start)
  assert(type(str) == 'string' and type(start) == 'string',  
         'starts_with:Err: string arguments expected')
  return str:sub(1, #start) == start
end
return Watcher
