" UltiSnips compatibility extension for neocomplcache.
" This provides snippet completion with neocomplcache
" and proper snippet expanding and jumping

let s:save_cpo = &cpoptions
set cpo&vim

let s:source = {
      \ 'name' : 'ultisnips_complete',
      \ 'kind' : 'manual',
      \ 'rank' : 9,
      \ 'hooks': {},
      \ 'min_pattern_length' :
      \    g:neocomplete#auto_completion_start_length,
      \ 'matchers': ['matcher_head']
      \}

function! s:source.hooks.on_init(context) "{{{
  " Append UltiSnips to python path
  "exec "py sys.path.append(vim.eval('g:UltiSnipsPythonPath'))"

  " Map completion function
  exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
  exec "snoremap <silent> " . g:UltiSnipsExpandTrigger . " <Esc>:call UltiSnips_ExpandSnippetOrJump()<cr>"
endfunction"}}}


" function! s:source.get_complete_position(context) "{{{
"   return match(a:context.input, '\S*$')
" endfunction"}}}

function! s:source.gather_candidates(context) "{{{
  let completions = s:get_words_list(a:context.complete_str)
  return completions
endfunction"}}}

" UltiSnips completion function that tries to expand a snippet. If there's no
" snippet for expanding, it checks for completion window and if it's
" shown, selects first element. If there's no completion window it tries to
" jump to next placeholder. If there's no placeholder it just returns TAB key
function! g:UltiSnips_Complete()
    call UltiSnips_ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            return "\<C-n>"
        else
            call UltiSnips_JumpForwards()
            if g:ulti_jump_forwards_res == 0
                return "\<TAB>"
            endif
        endif
    endif
    return ""
endfunction

" Get Completion list based on UltiSnips function used in <C-Tab> completion
" list
function! s:get_words_list(cur_word)
python << EOF
import vim
import sys
from UltiSnips import UltiSnips_Manager
import UltiSnips._vim as _vim
cur_word = vim.eval("a:cur_word")[:-1]
rawsnips = UltiSnips_Manager._snips(cur_word, True)

snips = []
for snip in rawsnips:
    display = {}
    display['menu'] = '<snip>' + snip.description
    display['word'] = snip.trigger
    display['kind'] = '~'
    snips.append(display)
vim.command("return %s" % _vim.escape(snips))
EOF
endfunction

function! neocomplete#sources#ultisnips_complete#define() "{{{
  return s:source
endfunction"}}}

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

