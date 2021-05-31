let s:Window = vital#fern_preview#import('VS.Vim.Window')
let s:FloatingWindow = vital#fern_preview#import('VS.Vim.Window.FloatingWindow')

let s:win = s:FloatingWindow.new()

call s:win.set_var('&number', 1)

if has('nvim')
  call s:win.set_var('&winhighlight', 'NormalFloat:Normal')
else
  call s:win.set_var('&wincolor', 'Normal')
endif

function! fern_preview#toggle_auto_preview() abort
  if g:fern_auto_preview
    let g:fern_auto_preview = v:false
    call fern_preview#close()
  else
    let g:fern_auto_preview = v:true
    call fern_preview#open()
  endif
endfunction

function! fern_preview#toggle() abort
  if s:win.is_visible()
    call fern_preview#close()
  else
    call fern_preview#open()
  endif
endfunction

function! fern_preview#cursor_moved() abort
  if g:fern_auto_preview
    call fern_preview#open()
  else
    call fern_preview#close()
  endif
endfunction

function! fern_preview#open() abort
  let helper = fern#helper#new()
  if helper.sync.get_scheme() !=# 'file'
    return
  endif

  let path = helper.sync.get_cursor_node()['_path']

  if isdirectory(path)
    call fern_preview#close()
    return
  endif

  call s:open_preview(path)
endfunction

function! fern_preview#close() abort
  call s:win.close()
endfunction

function! fern_preview#half_down() abort
  let winid = s:win.get_winid()
  let info = s:Window.info(winid)
  call s:Window.scroll(winid, info.topline + info.height / 2)
endfunction

function! fern_preview#half_up() abort
  let winid = s:win.get_winid()
  let info = s:Window.info(winid)
  call s:Window.scroll(winid, info.topline - info.height / 2)
endfunction

function! fern_preview#quit_or_close_preview() abort
  if s:win.is_visible()
    call fern_preview#close()
  else
    quit
  endif
endfunction

function! fern_preview#is_visible() abort
  return s:win.is_visible()
endfunction

function! s:open_preview(path) abort
  call s:win.set_bufnr(bufnr(a:path, v:true))
  call setbufvar(s:win.get_bufnr(), '&bufhidden', 'wipe')
  call setbufvar(s:win.get_bufnr(), '&buflisted', 0)
  call setbufvar(s:win.get_bufnr(), '&buftype', 'nofile')

  let width = min([g:fern_preview_max_width, &columns - 4, max([80, &columns - 80])])
  let height = min([g:fern_preview_max_height, &lines - 4, max([20, &lines - 20])])
  let top = ((&lines - height) / 2) - 1
  let left = (&columns - width) / 2

  call s:win.open({
  \   'row': top,
  \   'col': left,
  \   'width': width,
  \   'height': height,
  \   'topline': 1,
  \   'border': v:true,
  \ })
endfunction
