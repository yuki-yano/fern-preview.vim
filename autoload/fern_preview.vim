let s:Buffer         = vital#fern_preview#import('VS.Vim.Buffer')
let s:Window         = vital#fern_preview#import('VS.Vim.Window')
let s:FloatingWindow = vital#fern_preview#import('VS.Vim.Window.FloatingWindow')

let s:win = s:FloatingWindow.new()

call s:win.set_var('&number', 1)

if has('nvim')
  call s:win.set_var('&winhighlight', g:fern_preview_window_highlight)
else
  call s:win.set_var('&wincolor', g:fern_preview_window_highlight)
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

  if s:is_ignore_filetype(path)
    call fern_preview#close()
    echohl WarningMsg
    echomsg 'Ignore filetype: ' . path
    echohl None
    return
  endif

  if s:is_binary(path)
    call fern_preview#close()
    echohl WarningMsg
    echomsg 'Binary file: ' . path
    echohl None
    return
  endif

  if !s:is_valid_filesize(path)
    call fern_preview#close()
    echohl WarningMsg
    echomsg 'Too large filesize: ' . path
    echohl None
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

function! s:cursor_moved() abort
  if &filetype !=# 'fern'
    autocmd! fern-preview-control-window * <buffer>
    return
  endif

  if !has('nvim') && !g:fern_auto_preview && s:line ==# line('.')
    return
  endif

  if !has('nvim') && !g:fern_auto_preview
    autocmd! fern-preview-control-window * <buffer>
  endif

  if g:fern_auto_preview
    call fern_preview#open()
  else
    call fern_preview#close()
  endif
endfunction

function! s:define_autocmd() abort
  augroup fern-preview-control-window
    autocmd! * <buffer>
    autocmd BufLeave <buffer> call fern_preview#close()
    if has('nvim')
      autocmd CursorMoved <buffer> ++nested ++once call timer_start(0, { -> s:cursor_moved() })
    else
      autocmd CursorMoved <buffer> ++nested        call timer_start(0, { -> s:cursor_moved() })
    endif
  augroup END
endfunction

function! s:is_ignore_filetype(path) abort
  for ext in g:fern_preview_ignore_extensions
    if match(a:path, '\.' . ext . '$') !=# -1
      return v:true
    endif
  endfor

  return v:false
endfunction

function! s:is_valid_filesize(path) abort
  return getfsize(a:path) < g:fern_preview_max_filesize
endfunction

function! s:is_binary(path) abort
  for b in readfile(a:path, 'b', 3)
    if stridx(b, "\<NL>") != -1
      return v:true
    endif
  endfor

  return v:false
endfunction
