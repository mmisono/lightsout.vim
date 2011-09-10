"=============================================================================
" Name: lightsout.vim
" Author: mfumi
" Email: m.fumi760@gmail.com
" Version: 0.0.1

if exists('g:loaded_lightsout_vim')
	finish
endif
let g:loaded_lightsout_vim = 1

let s:save_cpo = &cpo
set cpo&vim

" ----------------------------------------------------------------------------

let s:poslist = []
let s:x = 0
let s:y = 0
let s:board = [[0,0,0,0,0],
			\[0,0,0,0,0],
			\[0,0,0,0,0],
			\[0,0,0,0,0],
			\[0,0,0,0,0]]

function! s:LightsOut()

	let winnum = bufwinnr(bufnr('\*LightsOut\*'))
	if winnum != -1
		if winnum != bufwinnr('%')
			exe "normal \<c-w>".winnum."w"
		endif
	else
		exec 'silent split \*LightsOut\*'
	endif

	setl nonumber
	setl noswapfile
	setl modifiable
	silent %d _

	" make postion list & board clear
	let i = 0
	while i < 5
		let j = 0
		call add(s:poslist,[])
		while j < 5
			call add(s:poslist[i],[0,1+i*3,1+j*6,0])
			let s:board[i][j] = 0
			let j += 1
		endwhile
		let i += 1
	endwhile


	" shuffle
	if has('reltime')
		let i = 0
		let dx = [-1,0,0,0,1]
		let dy = [0,-1,0,1,0]
		while i < 20
			let match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
			let rand_x = reltimestr(reltime())[l:match_end : ] % 5
			let match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
			let rand_y = reltimestr(reltime())[l:match_end : ] % 5

			call s:flip(rand_x,rand_y,"shuffle")
			let i += 1
		endwhile
	endif

	call s:draw()

	syn match LightsOutOn  "O"
	syn match LightsOutOff "\."
	hi LightsOutOn  ctermbg=red ctermfg=red guifg=Red guibg=Red
	hi LightsOutOff ctermbg=cyan ctermfg=cyan guibg=cyan guifg=cyan

	nnoremap <buffer> <silent> x :call <SID>_flip()<CR>
	nnoremap <buffer> <silent> h :call <SID>left()<CR>
	nnoremap <buffer> <silent> j :call <SID>down()<CR>
	nnoremap <buffer> <silent> k :call <SID>up()<CR>
	nnoremap <buffer> <silent> l :call <SID>right()<CR>

	setl nomodified
	setl nomodifiable
	setl bufhidden=delete
endfunction

function! s:draw()
	setl modifiable
	silent %d _

	let i = 0
	while i < 5
		let k = 0
		while k < 2
			let j = 0
			while j < 5
				if s:board[i][j] == 0
					normal 5A.
				else
					normal 5AO
				endif
				exe "normal A "
				let j += 1
			endwhile 
			let k += 1
			exe "normal A"
		endwhile
		exe "normal 29A "
		exe "normal A"
		let i += 1
	endwhile
	normal G
	silent d _
	silent d _
	normal gg

	setl nomodified
	setl nomodifiable
endfunction

function! s:_flip()
	call s:flip(s:x,s:y,"dummy")
endfunction

function! s:flip(x,y,type)
	setl modifiable
	let curpos = getpos('.')
	let dx = [-1,0,0,0,1]
	let dy = [0,-1,0,1,0]

	let i = 0
	while i < 5
		let mx = a:x + dx[i]
		let my = a:y + dy[i]
		if (mx >= 0 && my >= 0 && mx < 5 && my < 5)
			let s:board[my][mx] = 1 - s:board[my][mx]
			if a:type != "shuffle"
				call setpos('.',s:poslist[my][mx])
				if s:board[my][mx] == 0
					exe "normal \<c-v>lllljr."
				else
					exe "normal \<c-v>lllljrO"
				endif
			endif
		endif
		let i+= 1
	endwhile

	call setpos('.',curpos)
	setl nomodified
	setl nomodifiable
endfunction

function! s:left()
	if s:x > 0
		let s:x -= 1
		call setpos('.',s:poslist[s:y][s:x])
	endif
endfunction

function! s:right()
	if s:x < 4
		let s:x += 1
		call setpos('.',s:poslist[s:y][s:x])
	endif
endfunction

function! s:up()
	if s:y > 0
		let s:y -= 1
		call setpos('.',s:poslist[s:y][s:x])
	endif
endfunction

function! s:down()
	if s:y < 4
		let s:y += 1
		call setpos('.',s:poslist[s:y][s:x])
	endif
endfunction

command! -nargs=0 LightsOut call s:LightsOut()

" ----------------------------------------------------------------------------

let &cpo = s:save_cpo
unlet s:save_cpo

