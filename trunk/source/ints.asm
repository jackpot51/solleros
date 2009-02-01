newints:	;;for great justice
	cmp ah, 0		;;originally 0
	je near int300	;;0=kills app
	cmp ah, 6		;;originally 6
	je near int301	;;1=print char
	cmp ah, 5		;;originally 5		
	je near int302	;;2=get char
	cmp ah, 1		;;originally 1
	je near int303	;;3=print string
	cmp ah, 2		;;originally 2
	je near int304	;;4=read string
	cmp ah, 4		;;originally 4
	je near int305	;;5=read and print string
	cmp ah, 3		;;originally 3
	je near int306	;;6=clear screen
	ret
	
int300:	;;kill app
	jmp nwcmd
	
linebeginpos dw 0
videobufpos: dw 0
charpos db 0,0
charxy db 160,30
charbuf dw 0

int301:	;;print char, char in al, modifier in bl, will run videobuf2copy if called as is
	call int301prnt
	jmp videobuf2copy
int301prnt:
	mov ah, bl
	mov [charbuf], ax
	mov ebx, 0
	mov bx, [videobufpos]
	mov edi, videobuf2
	add edi, ebx
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
		mov [edi], ax
		sub edi, 2
		mov [edi], ax
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
	jmp videobuf2copy
		ret
	
endkey304 db 0
	int304:	;;get line, al=last key, esi = buffer
		mov [endkey304], al
	int304b:
		mov [currentesi], esi
		mov al, 0
		call int302
		mov esi, [currentesi]
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
currentesi dd 0
	int305:	;;print and get line, al=last key, bl=modifier, esi=buffer
		mov [endkey305], al
		mov [modkey305], bl
		mov [firstesi305], esi
	int305b:
		mov [currentesi], esi
		mov al, 0
		call int302
		mov esi, [currentesi]
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
		ret
	
scancode:
	db 0,0		;,0h
	db 0,0		;,1h
	db '1','!'	;,2h
	db '2','@'	;,3h
	db '3','#'	;,4h
	db '4','$'	;,5h
	db '5','%'	;,6h
	db '6','^'	;,7h
	db '7','&'	;,8h
	db '8','*'	;,9h
	db '9','('	;,0Ah
	db '0',')'	;,0Bh
	db '-','_'	;,0Ch
	db '=','+'	;,0Dh
	db 8,8		;,0Eh
	db 0,0		;,0Fh
	db 'q','Q'	;,10h
	db 'w','W'	;,11h
	db 'e','E'	;,12h
	db 'r','R'	;,13h
	db 't','T'	;,14h
	db 'y','Y'	;,15h
	db 'u','U'	;,16h
	db 'i','I'	;,17h
	db 'o','O'	;,18h
	db 'p','P'	;,19h
	db '[','{'	;,1Ah
	db ']','}'	;,1Bh
	db 0,0		;,1Ch
	db 0,0		;,1Dh
	db 'a','A'	;,1Eh
	db 's','S'	;,1Fh
	db 'd','D'	;,20h
	db 'f','F'	;,21h
	db 'g','G'	;,22h
	db 'h','H'	;,23h
	db 'j','J'	;,24h
	db 'k','K'	;,25h
	db 'l','L'	;,26h
	db ';',':'	;,27h
	db 27h,22h	;,28h
	db '`','~'	;,29h
	db 0,0		;,2Ah
	db '\','|'	;,2Bh
	db 'z','Z'	;,2Ch
	db 'x','X'	;,2Dh
	db 'c','C'	;,2Eh
	db 'v','V'	;,2Fh
	db 'b','B'	;,30h
	db 'n','N'	;,31h
	db 'm','M'	;,32h
	db ',','<'	;,33h
	db '.','>'	;,34h
	db '/','?'	;,35h
	db 0,0		;,36h
	db 0,0		;,37h
	db 0,0		;,38h
	db ' ',' '	;,39h
noscan:
