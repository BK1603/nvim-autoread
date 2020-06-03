if exists('g:loaded_watcher_provider')
  finish
endif

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to vim defaults

command! -nargs=1 Watch call luaeval("require('autoread').watch(_A)", expand('<args>')) 
command! -nargs=1 Stop call luaeval("require('autoread').stop_watch(_A)", expand('<args>'))

augroup autoread
  autocmd!
  au BufRead * Watch <afile>
  au BufDelete,BufUnload * Stop <afile>
augroup END

let &cpo = s:save_cpo " restore user coptions
unlet s:save_cpo

let g:loaded_watcher_provider = 1
