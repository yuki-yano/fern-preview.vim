if exists('g:loaded_fern_preview')
  finish
endif
let g:loaded_fern_preview = 1

if !exists('g:fern_auto_preview')
  let g:fern_auto_preview = v:false
endif

if !exists('g:fern_preview_width_ratio')
  let g:fern_preview_width_ratio = 0.8
endif

if !exists('g:fern_preview_max_width')
  let g:fern_preview_max_width = v:null
endif

if !exists('g:fern_preview_height_ratio')
  let g:fern_preview_height_ratio = 0.8
endif

if !exists('g:fern_preview_max_height')
  let g:fern_preview_max_height = v:null
endif

call add(g:fern#scheme#file#mapping#mappings, 'preview')
