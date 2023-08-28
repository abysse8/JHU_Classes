let g:vimtex_quickfix_mode=0
highlight Conceal ctermfg=7 ctermbg=NONE
syntax on
highlight Underlined ctermfg=144 guifg=#afaf87
highlight PreProc ctermfg=133 guifg=#af5fd7

set conceallevel=1
let g:tex_conceal='abdmg'
let g:vimtex_view_method = 'zathura'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsEditSplit = 'vertical'
call plug#begin()
Plug 'sirver/ultisnips'
Plug 'lervag/vimtex'
Plug 'artanikin/vim-synthwave84'
call plug#end()
