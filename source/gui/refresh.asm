guiclear:
	mov edi, [physbaseptr]
	mov dx, [resolutionx]
	mov cx, [resolutiony]
%ifdef gui.background
	cmp dword [backgroundimage], 0
	je guiclear.noback
		mov esi, [backgroundimage]
	.lp:
		;movdqa xmm0, [esi]	;the next 4 lines are for SSE
		;movdqa [edi], xmm0
		;add esi, 16
		;add edi, 16
		;sub dx, 8
		mov eax, [esi]
		mov [edi], eax
		add esi, 4
		add edi, 4
		sub dx, 2
		cmp dx, 0
		ja .lp
		dec cx
		mov dx, [resolutionx]
		cmp cx, 0
		ja .lp
		ret
	backgroundimage dd 0
%endif
guiclear.noback:
	mov eax, [background]
guiclearloop:
	mov [edi], eax
	add edi, 4
	sub dx, 2
	cmp dx, 0
	ja guiclearloop
	dec cx
	mov dx, [resolutionx]
	cmp cx, 0
	ja guiclearloop
	ret

background times 2 dw 0111101111001111b

reloadallgraphics:
		mov edi, graphicstable
reloadgraphicsloop:
		mov esi, [edi + 2]
		mov dx, [edi + 6]
		mov cx, [edi + 8]
		mov ax, [edi]
		mov bx, [edi + 10]
		mov [grpctblpos], edi
		cmp edi, [dragging]
		je loadedgraphic
		cmp ax, 1
		je near icongraphic
		cmp ax, 2
		je near stringgraphic
		cmp ax, 3
		je near windowgraphic
loadedgraphic:  mov edi, [grpctblpos]
		add edi, 16
		cmp edi, graphicstableend
		jae donereloadgraphics
		jmp reloadgraphicsloop
windowgraphic:
		call showwindow2
		call cleardouble
		jmp loadedgraphic
icongraphic:	and bl, 1
		mov [iconselected], bl
		call showicon2
		jmp loadedgraphic
stringgraphic:  and bl, 1
		mov [mouseselecton], bl
		call showstring2
		jmp loadedgraphic
donereloadgraphics:
		mov edi, [dragging]
		cmp edi, graphicstable
		jb notcorrectdrag
		mov ax, [edi]
		mov esi, [edi + 2]
		mov dx, [edi + 6]
		mov cx, [edi + 8]
		mov bx, [edi + 10]
		cmp ax, 1
		jne noticondragging
		and bl, 1
		mov [iconselected], bl
		call showicon2
notcorrectdrag:
		ret

	noticondragging:
		cmp ax, 2
		jne notcorrectdrag
		and bl, 1
		mov [mouseselecton], bl
		call showstring2
		jmp notcorrectdrag
