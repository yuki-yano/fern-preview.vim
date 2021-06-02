let s:Buffer         = vital#fern_preview#import('VS.Vim.Buffer')
let s:Window         = vital#fern_preview#import('VS.Vim.Window')
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

function! fern_preview#disable_auto_preview() abort
  let g:fern_auto_preview = v:false
endfunction

function! fern_preview#enable_auto_preview() abort
  let g:fern_auto_preview = v:true
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
  if !has('nvim') && !g:fern_auto_preview && s:line ==# line('.')
    return
  endif

  if g:fern_auto_preview
    call fern_preview#open()
  else
    call fern_preview#close()
  endif
endfunction

function! fern_preview#fern_open_or_change_dir() abort
  call fern_preview#close()

  if g:fern_auto_preview
    call fern_preview#open()
  endif
endfunction

function! fern_preview#open() abort
  let helper = fern#helper#new()
  if helper.sync.get_scheme() !=# 'file'
    return
  endif

  let path = helper.sync.get_cursor_node()['_path']

  if !has('nvim')
    let s:line = line('.')
  endif
  call s:define_autocmd()

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

function! fern_preview#width_default_func() abort
  let width = float2nr(&columns * 0.8)
  return width
endfunction

function! fern_preview#height_default_func() abort
  let height = float2nr(&lines * 0.8)
  return height
endfunction

function! fern_preview#left_default_func() abort
  let left = (&columns - call(g:fern_preview_window_calculator.width, [])) / 2
  return left
endfunction

function! fern_preview#top_default_func() abort
  let top = ((&lines - call(g:fern_preview_window_calculator.height, [])) / 2) - 1
  return top
endfunction

function! s:open_preview(path) abort
  let bufnr = s:Buffer.pseudo(a:path)
  call s:win.set_bufnr(bufnr)

  call setbufvar(bufnr, '&bufhidden', 'wipe')
  call setbufvar(bufnr, '&buflisted', 0)
  call setbufvar(bufnr, '&buftype', 'nofile')
  call setbufvar(bufnr, '&swapfile', 0)
  call setbufvar(bufnr, '&undofile', 0)

  let width  = call(g:fern_preview_window_calculator.width, [])
  let height = call(g:fern_preview_window_calculator.height, [])
  let left   = call(g:fern_preview_window_calculator.left, [])
  let top    = call(g:fern_preview_window_calculator.top, [])

  call s:win.open({
  \   'row': top,
  \   'col': left,
  \   'width': width,
  \   'height': height,
  \   'topline': 1,
  \   'border': v:true,
  \ })
endfunction

function! s:define_autocmd() abort
  augroup fern-preview-control-window
    autocmd! * <buffer>
    autocmd BufLeave <buffer> call fern_preview#close()
    if has('nvim')
      autocmd CursorMoved <buffer> ++nested ++once call fern_preview#cursor_moved()
    else
      autocmd CursorMoved <buffer> ++nested        call fern_preview#cursor_moved()
    endif
  augroup END
endfunction
