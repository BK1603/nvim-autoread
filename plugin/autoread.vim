if exists('g:loaded_watcher_provider')
  finish
endif

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to vim defaults

command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))
command! -nargs=1 Stop call luaeval('stop_watch(_A)', expand('<args>'))

let &cpo = s:save_cpo " restore user coptions
unlet s:save_cpo

let g:loaded_watcher_provider = 1
