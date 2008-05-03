; Etch.asm:
;  Etch-a-sketch simulation program
;
; keys:
;   a   = move up
;   z   = move down
;   ,   = move left
;   .   = move right
;   s   = shake etch-a-sketch (clears drawing)
;   esc = quit
;
	etchmsg db "Use the arrow keys to move ",34,"s",34," to clear the screen, and ",34,"esc",34," to exit.",0
etch:
	 mov si, etchmsg
	 call print
	 call getkey
	call realmode
         mov   ax, 0013h
         int   10h

dispmouse: mov   di, 0A000h
         mov   es, di
         mov   di, (99 * 320) + 159
	jmp NextPixel
      NextPixel:
         mov   byte [es:di], 15

         mov   ah, 00h
    	int 16h

;	cmp BYTE [MOUSEON], 1
;	je retmouse

         cmp   ah, 01h
         je    QuitProgram

         cmp   ah, 1Fh
         jne   NotShake

         mov   ax, 0013h
         int   10h
	jmp NotShake

retmouse: ret

      NotShake:
         cmp   ah, 48h
         jne   NotMoveUp

         sub   di, 320

      NotMoveUp:
         cmp   ah, 50h
         jne   NotMoveDown

         add   di, 320

      NotMoveDown:
         cmp   ah, 4Bh
         jne   NotMoveLeft

         dec   di

      NotMoveLeft:
         cmp   ah, 4Dh
         jne   NotMoveRight

         inc   di

      NotMoveRight:
         jmp   NextPixel

      QuitProgram:
	cmp BYTE [vga], 1
	je vgaquitetch
	mov ax, 3h
	int 10h
	call clear
         jmp nwcmd
	
vgaquitetch: mov ax, 3h
	int 10h
	call clear
  	call pmode
         jmp nwcmd