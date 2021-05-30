let s:Buffer = vital#fern_preview#import('VS.Vim.Buffer')
let s:Window = vital#fern_preview#import('VS.Vim.Window')
let s:FloatingWindow = vital#fern_preview#import('VS.Vim.Window.FloatingWindow')

let s:win = s:FloatingWindow.new()

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
    call fern_preview#close()
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
  call s:Window.scroll(winid, s:Window.info(winid).topline + s:height / 2)
endfunction

function! fern_preview#half_up() abort
  let winid = s:win.get_winid()
  call s:Window.scroll(winid, s:Window.info(winid).topline - s:height / 2)
endfunction

function! s:open_preview(path) abort
  call fern_preview#close()

  let bufnr = s:Buffer.load(a:path)
  call s:win.set_bufnr(bufnr)

  let width = min([&columns - 4, max([80, &columns - 80])])
  let s:height = min([&lines - 4, max([20, &lines - 20])])
  let top = ((&lines - s:height) / 2) - 1
  let left = (&columns - width) / 2

  call s:win.open({
  \   'row': top,
  \   'col': left,
  \   'width': width,
  \   'height': s:height,
  \   'topline': 1,
  \ })

  if has('nvim')
    call nvim_win_set_option(s:win.get_winid(), 'winhl', 'Normal:Normal')
  endif

  " TODO: set preview window
endfunction
