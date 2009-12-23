db 255,44,"cd",0
cd:
	mov esi, [currentcommandloc]
	add esi, 3
	mov edi, [currentfolderloc]
	mov [lastfolderloc], edi
	add edi, currentfolder
	;cmp word [esi], ".."
	;je .moveup
.movedown:
	mov al, [esi]
	mov [edi], al
	inc edi
	inc esi
	cmp al, 0
	je .donecd
	cmp edi, currentfolderend
	jb .movedown
	xor al, al
.donecd:
	dec edi
	mov byte [edi], '/'
	inc edi
	sub edi, currentfolder
	mov [currentfolderloc], edi
	ret
;.moveup:
;	ret
