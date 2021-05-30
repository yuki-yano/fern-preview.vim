if exists('g:loaded_fern_preview')
  finish
endif
let g:loaded_fern_preview = 1

if !exists('g:fern_auto_preview')
  let g:fern_auto_preview = v:false
endif

if !exists('g:fern_preview_default_mapping')
  let g:fern_preview_default_mapping = v:true
endif

nnoremap <Plug>(fern-action-preview:toggle)              :<C-u>call fern_preview#toggle()<CR>
nnoremap <Plug>(fern-action-preview:toggle-auto-preview) :<C-u>call fern_preview#toggle_auto_preview()<CR>

nnoremap <Plug>(fern-action-preview:half-down) :<C-u>call fern_preview#half_down()<CR>
nnoremap <Plug>(fern-action-preview:half-up)   :<C-u>call fern_preview#half_up()<CR>

function! s:fern_settings() abort
  if g:fern_preview_default_mapping
    nmap <silent> <buffer> <nowait> p <Plug>(fern-action-preview:toggle)
    nmap <silent> <buffer> <nowait> P <Plug>(fern-action-preview:toggle-auto-preview)

    nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:half-down)
    nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:half-up)
  endif

  autocmd BufLeave    <buffer>          call fern_preview#close()
  autocmd CursorMoved <buffer> ++nested call fern_preview#cursor_moved()
endfunction

autocmd FileType fern call s:fern_settings()
