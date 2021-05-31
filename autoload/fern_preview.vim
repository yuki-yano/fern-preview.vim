let s:Window = vital#fern_preview#import('VS.Vim.Window')
let s:FloatingWindow = vital#fern_preview#import('VS.Vim.Window.FloatingWindow')

let s:win = s:FloatingWindow.new()

call s:win.set_var('&number', 1)

if has('nvim')
  call s:win.set_var('&winhighlight', 'NormalFloat:Normal')
else
  call s:win.set_var('&wincolor', 'Normal')
endif

function! fern_preview#smart_preview(preview, non_preview) abort
  if s:win.is_visible()
    return a:preview
  else
    return a:non_preview
  endif
endfunction

function! fern_preview#buf_read() abort
  let bufnr = expand('<abuf>') + 0

  call setbufvar(bufnr, '&bufhidden', 'wipe')
  call setbufvar(bufnr, '&buflisted', 0)
  call setbufvar(bufnr, '&buftype', 'nofile')
  call setbufvar(bufnr, '&swapfile', 0)
  call setbufvar(bufnr, '&undofile', 0)

  call setline(1, readfile(substitute(expand('<afile>'), '^fern_preview://', '', 'g')))
  filetype detect
endfunction

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

  augroup fern-preview-open
    autocmd! * <buffer>
    autocmd WinLeave    <buffer> ++once          call fern_preview#close()
    autocmd CursorMoved <buffer> ++nested ++once call fern_preview#cursor_moved()
  augroup END

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

function! fern_preview#is_visible() abort
  return s:win.is_visible()
endfunction

function! fern_preview#width_default_func() abort
  let width = float2nr(&columns * 0.8)
  return width
endfunction

function! fern_preview#height_default_func() abort
  let height = float2nr(&lines * 0.8)
  return height
endfunction

function! s:open_preview(path) abort
  call s:win.set_bufnr(bufnr('fern_preview://' . a:path, v:true))

  let width  = call(g:fern_preview_window_calculator.width, [])
  let height = call(g:fern_preview_window_calculator.height, [])
  let top    = ((&lines - height) / 2) - 1
  let left   = (&columns - width) / 2

  call s:win.open({
  \   'row': top,
  \   'col': left,
  \   'width': width,
  \   'height': height,
  \   'topline': 1,
  \   'border': v:true,
  \ })
endfunction
