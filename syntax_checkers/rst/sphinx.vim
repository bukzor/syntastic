"============================================================================
"File:        sphinx.vim
"Description: Syntax checking plugin for Sphinx reStructuredText files
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_rst_sphinx_checker")
    finish
endif
let g:loaded_syntastic_rst_sphinx_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_rst_sphinx_GetLocList() dict

    let srcdir = syntastic#util#var('rst_sphinx_source_dir')
    if srcdir == ''
        let config = findfile('conf.py', '.;')
        if config == ''
            return []
        endif
        let srcdir = fnamemodify(config, ':p:h')
    endif

    let confdir = syntastic#util#var('rst_sphinx_config_dir')
    if confdir == ''
        let config = findfile('conf.py', '.;')
        let confdir = config != '' ? fnamemodify(config, ':p:h') : srcdir
    endif

    let tmpdir = syntastic#util#tmpdir()

    let makeprg = self.makeprgBuild({
        \ 'args': '-n',
        \ 'args_after': '-q -E -N -b pseudoxml -c ' . syntastic#util#shescape(confdir),
        \ 'fname': srcdir,
        \ 'fname_after': tmpdir })

    let errorformat =
        \ '%f:%l: %tRROR: %m,' .
        \ '%f:%l: %tARNING: %m,' .
        \ '%f:: %tRROR: %m,' .
        \ '%f:: %tARNING: %m,' .
        \ '%trror: %m,' .
        \ '%-G%.%#'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0] })

    call syntastic#util#rmrf(tmpdir)

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'rst',
    \ 'name': 'sphinx',
    \ 'exec': 'sphinx-build' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
