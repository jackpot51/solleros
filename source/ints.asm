newints:	;for great justice
	cmp ah, 0
	je near exitprog   ;kills app
	cmp ah, 1
	je near prntstr  ;print string
	cmp ah, 2
	je near readstr	;read string
	cmp ah, 3
	je near clearscrn	;clear screen
	cmp ah, 4
	je near prntreadstr	;read and print string
	cmp ah, 5
	je near readchar	;get char
	cmp ah, 6
	je near prntchar	;print char
	cmp ah, 7
	je near openfile	;read file
;	cmp ah, 8
;	je near closefile	;close file
	cmp ah, 9
	je near num2str	;convert number to string
	cmp ah, 10
	je near str2num	;convert string to number
%ifdef threads.included
	cmp ah, 11
	je near forkthread	;create thread
%endif
	cmp ah, 12
	je near gettime	;get time
	cmp ah, 13
	je near settime	;set time
	cmp ah, 14
	je near runcmd	;run program
	cmp ah, 15
	je near proginfo ;get program info-location of name/options/number of options/environmental vars
	cmp ah, 16
	je near hooksig	;hook code to a signal
%ifdef gui.included
	cmp ah, 17
	je near guiint	;GUI operations
%endif
%ifdef sound.included
	cmp ah, 18
	je near soundint	;sound operations
%endif
%ifdef network.included
	cmp ah, 19
	je near netint	;networking operations
%endif
	iret
	%include 'source/interrupts/0_exitprog.asm'
	%include 'source/interrupts/1_prntstr.asm'
	%include 'source/interrupts/2_readstr.asm'
	%include 'source/interrupts/3_clearscrn.asm'
	%include 'source/interrupts/4_prntreadstr.asm'
	%include 'source/interrupts/5_readchar.asm'
	%include 'source/interrupts/6_prntchar.asm'
	%include 'source/interrupts/7_openfile.asm'
	%include 'source/interrupts/9_num2str.asm'
	%include 'source/interrupts/10_str2num.asm'
%ifdef threads.included
	%include 'source/interrupts/11_forkthread.asm'
%endif
	%include 'source/interrupts/12_gettime.asm'
	%include 'source/interrupts/13_settime.asm'
	%include 'source/interrupts/14_runcmd.asm'
	%include 'source/interrupts/15_proginfo.asm'
	%include 'source/interrupts/16_hooksig.asm'
%ifdef gui.included
	%include 'source/interrupts/17_guiint.asm'
%endif
%ifdef sound.included
	%include 'source/interrupts/18_soundint.asm'
%endif
%ifdef network.included
	%include 'source/interrupts/19_netint.asm'
%endif

termcopy:
%ifdef io.serial
	ret
%else
%ifdef terminal.vsync
	mov byte [termcopyneeded], 1
	ret
%else
	call newtermcopy
	ret
%endif
	termcopyneeded db 0
	termcursorpos dd 0
	removedvideo dd 0
newtermcopy:
	pusha
	mov edi, videobuf
	xor ebx, ebx
	mov [termcopyneeded], bl
	mov ebx, [videobufpos]
	add edi, ebx
	mov [termcursorpos], edi
	call switchtermcursor
	cmp byte [guion], 0
	je near nowincopy
%ifdef gui.included
	mov byte [mouseselecton], 0
	mov byte [termcopyon], 1
	cmp byte [termguion], 1
	je near windowvideocopy
%endif
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
	mov eax, [edi]
	add edi, (videobuf2 - videobuf)
	mov ebx, [edi]
	mov [edi], eax
	sub edi, (videobuf2 - videobuf)
	add edi, 2
	cmp eax, ebx
	je nopresentwinfont
	sub edi, 2
	mov ebp, fonts
	xor eax, eax
	mov ax, [edi]
	shl eax, 4
	add ebp, eax
	add edi, 2
	mov bx, [edi]
	xor edx, edx
	mov dl, [charxy]
	rol ecx, 16
	mov cl, 16
nowinfont:
	mov al, [ebp]
	ror al, 1
	cmp bl, 0x80
	jb notnotfont
	not al
notnotfont:
	mov [esi], al
	add esi, edx
	inc ebp
	dec cl
	cmp cl, 0
	jne nowinfont
	shl edx, 4
	sub esi, edx
	rol ecx, 16
nopresentwinfont:
	add edi, 2
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
	mov ax, [edi + 2]
	mov bx, [edi]
	cmp ax, 0x80
	jb movlargecursorterm
	mov ax, 7
	jmp movedcursorterm
movlargecursorterm:
	mov ax, 0xF0
movedcursorterm:
	mov [edi + 2], ax
	cmp bx, 0
	jne fixednocursorterm
	mov bx, ' '
	mov [edi], bx
fixednocursorterm:
	ret
%endif
