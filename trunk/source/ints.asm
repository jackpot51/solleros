newints:	;for great justice
	cmp ah, 0
	je near intx0   ;kills app
	cmp ah, 1
	je near intx1   ;print string
	cmp ah, 2
	je near intx2	;read string
	cmp ah, 3
	je near intx3	;clear screen
	cmp ah, 4
	je near intx4	;read and print string
	cmp ah, 5
	je near intx5	;get char
	cmp ah, 6
	je near intx6	;print char
	cmp ah, 7
	je near intx7	;read file
;	cmp ah, 8
;	je near intx8	;write file
	cmp ah, 9
	je near intx9	;convert number to string
	cmp ah, 10
	je near intx10	;convert string to number
%ifdef threads.included
	cmp ah, 11
	je near intx11	;create thread
%endif
	cmp ah, 12
	je near intx12	;get time
	cmp ah, 13
	je near intx13	;set time
	cmp ah, 14
	je near intx14	;run program
	cmp ah, 15
	je near intx15	;get program info-location of name/options/number of options/environmental vars
	ret
	
;;the jmp timerinterrupt's ensure that task switches occur
intx0:
	%include 'source/interrupts/0_exit.asm'
intx1:
	%include 'source/interrupts/1_prntstr.asm'
intx2:
	%include 'source/interrupts/2_readstr.asm'
intx3:
	%include 'source/interrupts/3_clearscrn.asm'
intx4:
	%include 'source/interrupts/4_prntreadstr.asm'
intx5:
	%include 'source/interrupts/5_readchar.asm'
intx6:
	%include 'source/interrupts/6_prntchar.asm'
intx7:
	%include 'source/interrupts/7_openfile.asm'
intx9:
	%include 'source/interrupts/9_num2str.asm'
intx10:
	%include 'source/interrupts/10_str2num.asm'
%ifdef threads.included
intx11:
	%include 'source/interrupts/11_forkthread.asm'
%endif
intx12:
	%include 'source/interrupts/12_gettime.asm'
intx13:
	%include 'source/interrupts/13_settime.asm'
intx14:
	%include 'source/interrupts/14_runcmd.asm'
intx15:
	%include 'source/interrupts/15_proginfo.asm'
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
	removedvideo dw 0
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
	mov ax, [edi]
	add edi, (videobuf2 - videobuf)
	mov bx, [edi]
	mov [edi], ax
	sub edi, (videobuf2 - videobuf)
	inc edi
	cmp ax, bx
	je nopresentwinfont
	dec edi
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
%endif
