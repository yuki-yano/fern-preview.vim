if exists('g:loaded_fern_preview')
  finish
endif
let g:loaded_fern_preview = 1

if !exists('g:fern_auto_preview')
  let g:fern_auto_preview = v:false
endif

if !exists('g:fern_preview_window_calculator')
  let g:fern_preview_window_calculator = {}
endif

if !exists('g:fern_preview_window_calculator.width')
  let g:fern_preview_window_calculator.width = function('fern_preview#width_default_func')
endif

if !exists('g:fern_preview_window_calculator.height')
  let g:fern_preview_window_calculator.height = function('fern_preview#height_default_func')
endif

augroup fern-preview-internal
  autocmd!
  autocmd FileType   fern            call fern_preview#fern_open_or_change_dir()
  autocmd BufReadCmd fernpreview://* call fern_preview#buf_read()
augroup END

call add(g:fern#scheme#file#mapping#mappings, 'preview')
