newints:	;;for great justice
	cmp ah, 0		;;originally 0
	je near intx0   ;;0=kills app
	cmp ah, 1		;;originally 1
	je near intx1   ;;3=print string
	cmp ah, 2		;;originally 2
	je near intx2	;;4=read string
	cmp ah, 3		;;originally 3
	je near intx3	;;6=clear screen
	cmp ah, 4		;;originally 4
	je near intx4	;;5=read and print string
	cmp ah, 5		;;originally 5		
	je near intx5	;;2=get char
	cmp ah, 6		;;originally 6
	je near intx6	;;1=print char
	cmp ah, 7
	je near intx7	;;read file
	cmp ah, 9
	je near intx9	;;convert number to string
	cmp ah, 10
	je near intx10	;;convert string to number
	cmp ah, 11
	je near intx11	;;create thread
	ret
	
;;the jmp timerinterrupt's ensure that task switches occur
	
intx0:
	mov bx, NEW_DATA_SEL
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov bx, SYS_DATA_SEL
	mov gs, bx
	cmp al, 0
	jne near warnexitstatus
	jmp nwcmd
intx1:
	call int303
	jmp timerinterrupt
intx2:
	call int304
	jmp timerinterrupt
intx3:
	call int306
	jmp timerinterrupt
intx4:
	call int305
	jmp timerinterrupt
intx5:
	call int302
	jmp timerinterrupt
intx6:
	call int301
	jmp timerinterrupt
intx7:
	call loadfile
	jmp timerinterrupt
intx9:
	cmp al, 0
	jne intx9B
	call showdec
	jmp timerinterrupt
intx9B:
	call showhex
	jmp timerinterrupt
intx10:
	call cnvrttxt	;the string goes into esi, number into ecx
	iret
intx11:
	call threadfork
	iret
	
warnexitstatus:
	mov cl, al
	mov al, 0
	mov [firsthexshown], al
	push cx
	mov esi, exitstatus1msg
	call print
	pop cx
	call showhexsmall
	mov esi, exitstatus2msg
	call print
	jmp nwcmd
	
exitstatus1msg db "An exit status of 0x",0
exitstatus2msg db 8,"was returned.",10,13,0

linebeginpos dw 0
videobufpos: dw 0
charpos db 0,0
charxy db 80,30
charbuf dw 0
	
int301:	;;print char, char in al, modifier in bl, will run videobufcopy if called as is
	call int301prnt
	call termcopy
	ret
termguion db 0
termcopyon db 0
int301prnt:
	mov ah, bl
	mov [charbuf], ax
	xor ebx, ebx
	mov bx, [videobufpos]
	mov edi, videobuf
	add edi, ebx
	mov ax, [removedvideo]
	mov [edi], ax
	mov ax, [charbuf]
	xor edx, edx
	mov dx, [charpos]
	xor ecx, ecx
	mov cx, [charxy]
	cmp al, 9
	je near int301tab
	cmp al, 13
	je near int301cr
	cmp al, 10
	je near int301nl
	cmp al, 8
	je near int301bs
	cmp al, 255		;;null character
	je near donescr
	mov [edi], ax
	add edi, 2
	inc dl
donecrnl:
	cmp dl, cl
	jae near int301eol
doneeol:
	cmp dh, ch
	jae near int301scr	
donescr:
	mov ebx, edi
	mov ax, [edi]
	mov [removedvideo], ax
	sub ebx, videobuf
	mov [videobufpos], bx
	mov [charpos], dx
	mov ax, [charbuf]
	mov bl, ah
	ret
	
	int301tab:
		inc edi
		shr edi, 4
		shl edi, 4
		add edi, 16
		shr dl, 3
		shl dl, 3
		add dl, 8
		dec edi
		jmp donecrnl
	
	int301cr:
		xor dl, dl
		xor ebx, ebx
		mov edi, videobuf
		mov bx, [linebeginpos]
		add edi, ebx
		jmp donecrnl
			
	int301bs:
		cmp dl, 0
		je int301backline
	int301nobmr:
		dec dl
		xor ax, ax
		sub edi, 2
		jmp donecrnl
	int301backline:
		mov dl, cl
		cmp dh, 0
		je int301nobmr
		dec dh
		jmp int301nobmr
		
	int301nl:
		inc dh
		xor ebx, ebx
		mov bl, cl
		shl bx, 1
		mov edi, videobuf
		add bx, [videobufpos]
		add edi, ebx
		xor ebx, ebx
		mov bl, cl
		shl bx, 1
		add bx, [linebeginpos]
		mov [linebeginpos], bx
		jmp donecrnl
		
	int301eol:
		xor dl, dl
		inc dh
		xor ebx, ebx
		mov bl, cl
		shl bx, 1
		add bx, [linebeginpos]
		mov [linebeginpos], bx
		jmp doneeol
	int301scr:
		dec dh
		mov edi, videobuf
		xor ebx, ebx
		mov bl, cl
		shl bx, 1
		add ebx, edi
	intscrollloop:
		mov ax, [ebx]
		mov [edi], ax
		add edi, 2
		add ebx, 2
		dec cl
		cmp cl, 0
		jne intscrollloop
		mov cl, [charxy]
		dec ch
		cmp ch, 1
		ja intscrollloop
		xor ax, ax
		sub edi, videobuf
		mov [linebeginpos], di
		add edi, videobuf
		mov ebx, edi
	intloopclear:
		mov [ebx], ax
		add ebx, 2
		dec cl
		cmp cl, 0
		jne intloopclear
		dec ch
		cmp ch, 0
		jne intloopclear
		mov cx, [charxy]
		jmp donescr
		
		
lastkey db 0,0
trans db 0
getkey:
	xor al, al
	int302:		;;get char, if al is 0, wait for key
		mov byte [trans], 1
		cmp al, 1
		jae transcheck
		mov byte [trans], 0
	transcheck:
		call guistartin
		mov bh, [trans]
		mov ax, [lastkey]
		cmp ah, 1Ch
		je int302enter
		cmp byte [specialkey], 0xE0
		jne nospecialtrans
		mov bl, al
		xor al, al
	nospecialtrans:
		or bh, al
		cmp bh, 0
		je transcheck
		jmp int302end
	int302enter:
		mov al, 13
	int302end:
		ret
	
endkey303 db 0
	printquiet:
		xor ax, ax
		mov [endkey303], al
		mov bx, 7
		call int303b
		ret
    print:
		xor ax, ax
		mov bx, 7
	int303:	;;print line, al=last key,bl=modifier, esi=buffer
		mov [endkey303], al
		call int303b
		call termcopy
		ret
	int303b:
		mov al, [esi]
		cmp al, [endkey303]
		je doneint303
		call int301prnt
		inc esi
		jmp int303b
	doneint303:
		ret
		
endkey304 db 0
endbuffer304 dd 0
	int304:	;;get line, al=last key, esi = buffer, edi = endbuffer
		mov [endkey304], al
		mov [endbuffer304], edi
	int304b:
		push esi
		xor al, al
		call int302
		pop esi
		mov [esi], al
		inc esi
		cmp esi, [endbuffer304]
		jae int304done
		cmp al, [endkey304]
		jne int304b
	int304done:
		dec esi
		mov byte [esi], 0
	ret
	
endkey305 db 0
modkey305 db 0
firstesi305 dd 0
commandedit db 0
txtmask db 0
buftxtloc dd 0
endbuffer305 dd 0
backcursor db 8," ",0

readline:
  mov al, 13
  mov bl, 7
	int305:	;;print and get line, al=last key, bl=modifier, esi=buffer, edi=bufferend
		mov [buftxtloc], esi
		mov [endkey305], al
		mov [modkey305], bl
		mov [firstesi305], esi
		mov [endbuffer305], edi
	int305b:
		push esi
		mov al, 1
		call int302	;then get it
		pop esi
		cmp ah, 0x48
		je near int305up
		cmp ah, 0x50
		je near int305down
		cmp ah, 0x4D
		je near int305right
		cmp ah, 0x4B
		je near int305left
		cmp al, 8
		je near int305bscheck
		cmp al, 0
		je int305b
		cmp ah, 0
		je int305b
		mov [esi], al
		inc esi
	bscheckequal:
		mov bl, [modkey305]
		mov bh, [txtmask]
		cmp bh, 0
		je nomasktxt
		mov al, bh
	nomasktxt:
		call int301
		push esi
		mov [int305axcache], ax
		mov ah, [endkey305]
		cmp al, ah
		je nobackprintbuftxt2
		mov esi, buftxt2
		call printquiet
		mov al, " "
		call int301prnt
		mov al, 8
		cmp esi, buftxt2
		je nobackprintbuftxt2
	backprintbuftxt2:
		call int301prnt
		dec esi
		cmp esi, buftxt2
		ja backprintbuftxt2
	nobackprintbuftxt2:
		call int301
		pop esi
		cmp esi, [endbuffer305]
		jae near doneint305
		mov ax, [int305axcache]
		mov ah, [endkey305]
		cmp al, ah
		jne int305b
	doneint305:
		dec esi
		mov edi, buftxt2
	copylaterstuff:
		mov al, [edi]
		cmp al, 0
		je nocopylaterstuff
		mov [esi], al
		inc edi
		inc esi
		jmp copylaterstuff
	nocopylaterstuff:
		mov byte [esi], 0
		call clearbuftxt2
		ret
	
	clearbuftxt2:
		xor al, al
		mov edi, buftxt2
	clearbuftxt2lp:
		mov [edi], al
		inc edi
		cmp edi, buftxt
		jne clearbuftxt2lp
		ret
	
	int305b2:
		call termcopy
		jmp int305b
	
	int305axcache dw 0
		
	int305left:
		cmp esi, [buftxtloc]
		je near int305b
		mov edi, buftxt2
		mov al, [edi]
	shiftbuftxt2:
		cmp al, 0
		je noshiftbuftxt2
		inc edi
		mov ah, [edi]
		mov [edi], al
		mov al, ah
		jmp shiftbuftxt2
	noshiftbuftxt2:
		mov edi, buftxt2
		dec esi
		mov al, [esi]
		mov [edi], al
		mov byte [esi], 0
		mov al, 8
		call int301
		jmp int305b
		
	int305right:
		mov edi, buftxt2
		mov al, [edi]
		cmp al, 0
		je near int305b
		mov [esi], al
	shiftbuftxt2lft:
		cmp al, 0
		je noshiftbuftxt2lft
		inc edi
		mov al, [edi]
		mov [edi - 1], al
		jmp shiftbuftxt2lft
	noshiftbuftxt2lft:
		mov al, [esi]
		inc esi
		mov bl, [modkey305]
		call int301
		jmp int305b
		
	int305downbck:
		dec ah
		mov [commandedit], ah
		call int305bckspc
		jmp int305b
	
	int305down:
		mov ah, [commandedit]
		cmp ah, 1
		jbe near int305b
		cmp ah, 2
		je int305downbck
		sub ah, 2
		mov [commandedit], ah
		
	int305up:
		xor al, al
		cmp [commandedit], al
		je near int305b
		call int305bckspc
		jmp getcurrentcommandstr
	int305bckspc:
		cmp esi, [buftxtloc]
		je noint305upbck
	int305upbckspclp:
		mov al, 8
		mov bl, [modkey305]
		call int301prnt
		mov al, " "
		call int301prnt
		mov al, 8
		call int301prnt
		dec esi
		cmp esi, [buftxtloc]
		je noint305upbck2
		jmp int305upbckspclp
	noint305upbck2:
		call termcopy
	noint305upbck:
		mov edi, [currentcommandpos]
		add edi, commandbuf
		dec edi
		ret
	getcurrentcommandstr:
		mov ah, [commandedit]
		inc byte [commandedit]
	getccmdlp:
		dec edi
		mov al, [edi]
		cmp edi, commandbuf
		jb getcmdresetcommandbuf
		sub edi, commandbuf
		cmp edi, [currentcommandpos]
		je near int305b
		add edi, commandbuf
		cmp al, 0
		jne getccmdlp
		dec ah
		cmp ah, 0
		ja getccmdlp
		inc edi
		cmp edi, commandbufend
		ja fixcmdbufb4moreint305
		jmp moreint305up
	getcmdresetcommandbuf:
		mov edi, commandbufend
		inc edi
		jmp getccmdlp
	fixcmdbufb4moreint305:
		dec edi
		sub edi, commandbufend
		add edi, commandbuf
	moreint305up:
		mov al, [edi]
		inc edi
		sub edi, commandbuf
		cmp al, 0
		je near int305b2
		cmp edi, [currentcommandpos]
		jae near int305b2
		add edi, commandbuf
		mov [esi], al
		inc esi
		push edi
		mov bl, [modkey305]
		call int301prnt
		pop edi
		cmp edi, commandbufend
		jbe moreint305up
		mov edi, commandbuf
		jmp moreint305up
	int305bscheck:
		cmp esi, [firstesi305]
		ja goodbscheck
		jmp int305b
	goodbscheck:
		dec esi
		mov byte [esi], 0
		mov bl, [modkey305]
		mov al, 8
		jmp bscheckequal
	
		
	clear:		
	
	int306:	;;clear screen
		mov cx, [charxy]
		mov edi, videobuf
		xor ax, ax
		mov [linebeginpos], ax
		mov [videobufpos], ax
		xor dx, dx
		mov [charpos], ax
	int306b:
		mov [edi], ax
		add edi, 2
		dec cl
		cmp cl, 0
		jne int306b
		mov cl, [charxy]
		dec ch
		cmp ch, 0
		jne int306b
		call termcopy
		ret
		
	termcursorpos dd 0
	removedvideo dw 0
termcopy:	
	pusha
	mov edi, videobuf
	xor ebx, ebx
	mov bx, [videobufpos]
	add edi, ebx
	mov [termcursorpos], edi
	call switchtermcursor
	mov byte [mouseselecton], 0
	mov byte [termcopyon], 1
	cmp byte [guion], 0
	je near nowincopy
	cmp byte [termguion], 1
	je near windowvideocopy
	jmp nocopytermatall
nowincopy:
	mov esi, 0xA0000
	mov eax, [basecache]
	shl eax, 4
	sub esi, eax
	mov edi, videobuf
	xor ecx, ecx
	mov cx, [charxy]
nowincopy2:
	mov ebx, fonts
	xor eax, eax
	mov al, [edi]
	shl eax, 4
	add ebx, eax
	inc edi
	mov ah, [edi]
	xor edx, edx
	mov dl, [charxy]
	rol ecx, 16
	mov cl, 16
nowinfont:
	mov al, [ebx]
	ror al, 1
	cmp ah, 7
	jbe notnotfont
	not al
notnotfont:
	mov [esi], al
	add esi, edx
	inc ebx
	dec cl
	cmp cl, 0
	jne nowinfont
	shl edx, 4
	sub esi, edx
	rol ecx, 16
nopresentwinfont:
	inc edi
	inc esi
	dec cl
	cmp cl, 0
	jne nowincopy2
	mov cl, [charxy]
	xor edx, edx
	mov dl, cl
	sub esi, edx
	shl edx, 4
	add esi, edx
	dec ch
	cmp ch, 0
	jne nowincopy2
nocopytermatall:
	call switchtermcursor
	popa
	ret
	
switchtermcursor:
	mov edi, [termcursorpos]
	mov al, [edi + 1]
	mov ah, [edi]
	cmp al, 7
	jbe movlargecursorterm
	mov al, 7
	jmp movedcursorterm
movlargecursorterm:
	mov al, 0xF0
movedcursorterm:
	mov [edi + 1], al
	cmp ah, 0
	jne fixednocursorterm
	mov ah, " "
	mov [edi], ah
fixednocursorterm:
	ret
	
;FUTURE INTS
;sound
setpitch:
	mov al, 0xB6
	out 0x43, al
	mov ax, bx
	out 0x42, al
	mov al, ah
	out 0x42, al
	ret
startsound:
	in al, 0x61
	or al, 3
	out 0x61, al
	ret
killsound:
	in al, 0x61
	and al, 0xFC
	out 0x61, al
	ret