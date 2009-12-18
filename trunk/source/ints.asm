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
;	cmp ah, 8		;;write file
;	je near intx8
	cmp ah, 9
	je near intx9	;;convert number to string
	cmp ah, 10
	je near intx10	;;convert string to number
	cmp ah, 11
	je near intx11	;;create thread
	cmp ah, 12		;;get time
	je near intx12
	cmp ah, 13		;;set time
	je near intx13
	cmp ah, 14		;;run program
	je near intx14
	cmp ah, 15		;;get program info-location of name/options/number of options/environmental vars
	je near intx15
	ret
	
;;the jmp timerinterrupt's ensure that task switches occur
intx0:
	%include 'source/interrupts/0-exit.asm'
intx1:
	%include 'source/interrupts/1-prntstr.asm'
intx2:
	%include 'source/interrupts/2-readstr.asm'
intx3:
	%include 'source/interrupts/3-clearscrn.asm'
intx4:
	%include 'source/interrupts/4-prntreadstr.asm'
intx5:
	%include 'source/interrupts/5-readchar.asm'
intx6:
	%include 'source/interrupts/6-prntchar.asm'
intx7:
	%include 'source/interrupts/7-openfile.asm'
intx9:
	%include 'source/interrupts/9-num2str.asm'
intx10:
	%include 'source/interrupts/10-str2num.asm'
intx11:
	%include 'source/interrupts/11-forkthread.asm'
intx12:
	%include 'source/interrupts/12-gettime.asm'
intx13:
	%include 'source/interrupts/13-settime.asm'
intx14:
	%include 'source/interrupts/14-runcmd.asm'
intx15:
	%include 'source/interrupts/15-proginfo.asm'
		
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
