" Lazy-load helper functions for composition
"
" Description: Helper method for write md, tex and other non-coding files.
" Maintainer: quinoa42
" License: MIT {{{
" Copyright © 2019 quinoa42
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the "Software"),
" to deal in the Software without restriction, including without limitation
" the rights to use, copy, modify, merge, publish, distribute, sublicense,
" and/or sell copies of the Software, and to permit persons to whom the
" Software is furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included
" in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
" OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
" IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
" DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
" TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
" OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

function! composition#sane()
    setlocal wrap
    setlocal linebreak
    setlocal conceallevel=0
    noremap <buffer> j gj
    noremap <buffer> k gk
    noremap <buffer> $ g$
    noremap <buffer> ^ g^
    noremap <buffer> 0 g0
endfunction

" vim: foldenable:foldmethod=marker