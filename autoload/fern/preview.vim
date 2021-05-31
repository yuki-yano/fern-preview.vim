let s:Window = vital#fern_preview#import('VS.Vim.Window')
let s:FloatingWindow = vital#fern_preview#import('VS.Vim.Window.FloatingWindow')

let s:win = s:FloatingWindow.new()

call s:win.set_var('&number', 1)

if has('nvim')
  call s:win.set_var('&winhighlight', 'NormalFloat:Normal')
else
  call s:win.set_var('&wincolor', 'Normal')
endif

function! fern#preview#smart_preview(preview, non_preview) abort
  if s:win.is_visible()
    return a:preview
  else
    return a:non_preview
  endif
endfunction

function! fern#preview#toggle_auto_preview() abort
  if g:fern_auto_preview
    let g:fern_auto_preview = v:false
    call fern#preview#close()
  else
    let g:fern_auto_preview = v:true
    call fern#preview#open()
  endif
endfunction

function! fern#preview#toggle() abort
  if s:win.is_visible()
    call fern#preview#close()
  else
    call fern#preview#open()
  endif
endfunction

function! fern#preview#cursor_moved() abort
  if g:fern_auto_preview
    call fern#preview#open()
  else
    call fern#preview#close()
  endif
endfunction

function! fern#preview#open() abort
  let helper = fern#helper#new()
  if helper.sync.get_scheme() !=# 'file'
    return
  endif

  let path = helper.sync.get_cursor_node()['_path']

  if isdirectory(path)
    call fern#preview#close()
    return
  endif

  augroup fern-preview-open
    autocmd! * <buffer>
    autocmd WinLeave    <buffer> ++once          call fern#preview#close()
    autocmd CursorMoved <buffer> ++nested ++once call fern#preview#cursor_moved()
  augroup END

  call s:open_preview(path)
endfunction

function! fern#preview#close() abort
  call s:win.close()
endfunction

function! fern#preview#half_down() abort
  let winid = s:win.get_winid()
  let info = s:Window.info(winid)
  call s:Window.scroll(winid, info.topline + info.height / 2)
endfunction

function! fern#preview#half_up() abort
  let winid = s:win.get_winid()
  let info = s:Window.info(winid)
  call s:Window.scroll(winid, info.topline - info.height / 2)
endfunction

function! fern#preview#is_visible() abort
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
