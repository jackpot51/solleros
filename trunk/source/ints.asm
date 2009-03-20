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
	je near intx9	;;convert number
	cmp ah, 10
	je near intx10	;;create thread
	ret
	
intx0:
	jmp nwcmd
intx1:
	call int303
	ret
intx2:
	call int304
	ret
intx3:
	call int306
	ret
intx4:
	call int305
	ret
intx5:
	call int302
	ret
intx6:
	call int301
	ret
intx7:
	call loadfile
	ret
intx9:
	cmp al, 0
	jne intx9B
	call showdec
	ret
intx9B:
	call showhex
	ret
intx10:
;	call thread
	ret
	
linebeginpos dw 0
videobufpos: dw 0
charpos db 0,0
charxy db 160,30
charbuf dw 0

int301:	;;print char, char in al, modifier in bl, will run videobuf2copy if called as is
	call int301prnt
	jmp termcopy
termguion db 0
termcopyon db 0
int301prnt:
	mov ah, bl
	mov [charbuf], ax
	mov ebx, 0
	mov bx, [videobufpos]
	mov edi, videobuf2
	add edi, ebx
	mov ax, [removedvideo]
	mov [edi], ax
	mov ax, [charbuf]
	mov edx, 0
	mov dx, [charpos]
	mov ecx, 0
	mov cx, [charxy]
	cmp al, 13
	je near int301cr
	cmp al, 10
	je near int301nl
	cmp al, 8
	je near int301bs
	mov [edi], ax
	add edi, 2
	add dl, 2
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
	sub ebx, videobuf2
	mov [videobufpos], bx
	mov [charpos], dx
	mov ax, [charbuf]
	mov bl, ah
	ret
	
	int301cr:
		mov dl, 0
		mov ebx, 0
		mov edi, videobuf2
		mov bx, [linebeginpos]
		add edi, ebx
		jmp donecrnl
			
	int301bs:
		cmp dl, 0
		je int301backline
	int301nobmr:
		sub dl, 2
		mov ax, 0
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
		mov ebx, 0
		mov bl, cl
		mov edi, videobuf2
		add bx, [videobufpos]
		add edi, ebx
		mov ebx, 0
		mov bl, cl
		add bx, [linebeginpos]
		mov [linebeginpos], bx
		jmp donecrnl
		
	int301eol:
		mov dl, 0
		inc dh
		mov ebx, 0
		mov bl, cl
		add bx, [linebeginpos]
		mov [linebeginpos], bx
		jmp doneeol
		
	int301scr:
		dec dh
		mov edi, videobuf2
		mov ebx, 0
		mov bl, cl
		add ebx, edi
	intscrollloop:
		mov ax, [ebx]
		mov [edi], ax
		add edi, 2
		add ebx, 2
		sub cl, 2
		cmp cl, 0
		jne intscrollloop
		mov cl, [charxy]
		dec ch
		cmp ch, 1
		ja intscrollloop
		mov ax, 0
		sub edi, videobuf2
		mov [linebeginpos], di
		add edi, videobuf2
		mov ebx, edi
	intloopclear:
		mov [ebx], ax
		add ebx, 2
		sub cl, 2
		cmp cl, 0
		jne intloopclear
		dec ch
		cmp ch, 0
		jne intloopclear
		mov cx, [charxy]
		jmp donescr
		
		
lastkey db 0,0
trans db 0

	int302:		;;get char, if al is 0, wait for key
		mov [trans], al
	transcheck:
		call guistartin
		mov bh, [trans]
		mov ax, [lastkey]
		cmp ah, 1Ch
		je int302enter
		or bh, al
		cmp bh, 0
		je transcheck
		jmp int302end
	int302enter:
		mov al, 13
		jmp int302end
	int302end:
		ret
	
endkey303 db 0
    print:
		mov ax, 0
		mov bx, 7
	int303:	;;print line, al=last key,bl=modifier, esi=buffer
		mov [endkey303], al
	int303b:
		mov al, [esi]
		cmp al, [endkey303]
		je doneint303
		call int301prnt
		inc esi
		jmp int303b
	doneint303:
		jmp termcopy
	
endkey304 db 0
	int304:	;;get line, al=last key, esi = buffer
		mov [endkey304], al
	int304b:
		push esi
		mov al, 0
		call int302
		pop esi
		mov [esi], al
		inc esi
		cmp al, [endkey304]
		jne int304b
		dec esi
		mov byte [esi], 0
	ret
	
endkey305 db 0
modkey305 db 0
firstesi305 dd 0
backcursor db 8," ",0
	int305:	;;print and get line, al=last key, bl=modifier, esi=buffer
		mov [endkey305], al
		mov [modkey305], bl
		mov [firstesi305], esi
	int305b:
		push esi
		mov al, 0
		call int302
		pop esi
		cmp al, 8
		je near int305bscheck
		mov [esi], al
		inc esi
	bscheckequal:
		mov bl, [modkey305]
		call int301
		mov ah, [endkey305]
		cmp al, ah
		jne int305b
		dec esi
		mov byte [esi], 0
		ret
	
	int305bscheck:
		cmp esi, [firstesi305]
		ja goodbscheck
		jmp int305b
	goodbscheck:
		dec esi
		mov byte [esi], 0
		mov bl, [modkey305]
		push esi
		mov esi, backcursor
		call print		
		pop esi
		mov al, 8
		jmp bscheckequal
		
	clear:		
	
	int306:	;;clear screen
		mov cx, [charxy]
		mov edi, videobuf2
		mov ax, 0
		mov [linebeginpos], ax
		mov [videobufpos], ax
		mov dx, 0
		mov [charpos], ax
	int306b:
		mov [edi], ax
		add edi, 2
		sub cl, 2
		cmp cl, 0
		jne int306b
		mov cl, [charxy]
		dec ch
		cmp ch, 0
		jne int306b
	
	removedvideo dw 0
	
termcopy:	
	pusha
	mov edi, videobuf2
	mov ebx, 0
	mov bx, [videobufpos]
	add edi, ebx
	mov al, "_"
	mov ah, 7
	mov [edi], ax
	mov byte [mouseselecton], 0
	mov byte [termcopyon], 1
	cmp byte [guion], 0
	je near nowincopy
	cmp byte [termguion], 1
	je near windowvideocopy
nowincopy:
	mov esi, 0xA0000
	mov eax, [basecache]
	shl eax, 4
	sub esi, eax
	mov edi, videobuf2
	mov ecx, 0
	mov cx, [charxy]
nowincopy2:
	mov ebx, fonts
	mov eax, 0
	mov al, [edi]
	shl eax, 4
	add ebx, eax
	inc edi
	mov ah, [edi]
	mov edx, 0
	mov dl, [charxy]
	shr edx, 1
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
	sub cl, 2
	cmp cl, 0
	jne nowincopy2
	mov cl, [charxy]
	mov edx, 0
	mov dl, cl
	shr edx, 1
	sub esi, edx
	shl edx, 4
	add esi, edx
	dec ch
	cmp ch, 0
	jne nowincopy2
	popa
	ret
	