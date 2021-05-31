function! fern#scheme#file#mapping#preview#init(disable_default_mappings) abort
  nnoremap <silent> <buffer> <Plug>(fern-action-preview:open)                  :<C-u>call fern_preview#open()<CR>
  nnoremap <silent> <buffer> <Plug>(fern-action-preview:close)                 :<C-u>call fern_preview#close()<CR>
  nnoremap <silent> <buffer> <Plug>(fern-action-preview:toggle)                :<C-u>call fern_preview#toggle()<CR>
  nnoremap <silent> <buffer> <Plug>(fern-action-preview:toggle-auto-preview)   :<C-u>call fern_preview#toggle_auto_preview()<CR>
  nnoremap <silent> <buffer> <Plug>(fern-action-preview:quit_or_close_preview) :<C-u>call fern_preview#quit_or_close_preview()<CR>

  nnoremap <silent> <buffer> <Plug>(fern-action-preview:half-down) :<C-u>call fern_preview#half_down()<CR>
  nnoremap <silent> <buffer> <Plug>(fern-action-preview:half-up)   :<C-u>call fern_preview#half_up()<CR>
endfunction
