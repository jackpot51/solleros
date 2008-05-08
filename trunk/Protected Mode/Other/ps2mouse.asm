mouse:
		;;;;;IF YOU WANT DIAGNOSTICS REMOVE THE ; OR RET AFTER DISP AND DISPDEC AND GOTOXY ON int30hah*
call MAINP
.mainloop:
call mousemain
jmp .mainloop
;***********************************************************************
;Activate mouse port (PS/2)
;***********************************************************************
PS2SET:
  mov  al, 0xa8		; enable mouse port
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Check if command is accepted. (not got stuck in inputbuffer)
;***********************************************************************
CHKPRT:
  xor  cx, cx		
 .again:
  in   al, 0x64		; read from keyboardcontroller
  test al, 2		; Check if input buffer is empty
  je .go
  loop .again
 .go
ret

;***********************************************************************
;Write to mouse
;***********************************************************************
WMOUS:
  mov  al, 0xd4		; write to mouse device instead of to keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret



;***********************************************************************
;mouse output buffer full
;***********************************************************************
MBUFFUL:
  xor  cx, cx
 .mn:
  in   al, 0x64		; read from keyboardcontroller
  test al, 0x20		; check if mouse output buffer is full
  jz  .mnn
  loop .mn
 .mnn:
ret


;***********************************************************************
;Write activate Mouse HardWare
;***********************************************************************
ACTMOUS:
  call WMOUS
  mov  al, 0xf4 	; Command to activate mouse itselve (Stream mode)
  out  0x60, al		; write ps/2 controller output port (activate mouse)
  call CHKPRT		; check if command is progressed (demand!)
  call CHKMOUS		; check if a byte is available
ret

;***********************************************************************
;Check if mouse has info for us
;***********************************************************************
CHKMOUS:
  mov  bl, 0
  xor  cx, cx
 .vrd:
  in   al, 0x64		; read from keyboardcontroller
  test al, 1		; check if controller buffer (60h) has data
  jnz .yy
  loop .vrd
  mov  bl, 1
 .yy:
ret

;***********************************************************************
;Disable Keyboard
;***********************************************************************
DKEYB:
  call CHKPRT
  mov  al, 0xad		; Disable Keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Enable Keyboard
;***********************************************************************
EKEYB:
  call CHKPRT
  mov  al, 0xae		; Enable Keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Get Mouse Byte
;***********************************************************************
GETB:
 .cagain
  call CHKMOUS		; check if a byte is available
  or bl, bl
  jnz .cagain
  call DKEYB		; disable keyboard to read mouse byte
  xor  ax, ax
  in   al, 0x60		; read ps/2 controller output port (mousebyte)
  mov  dl, al
  call EKEYB		; enable keyboard
  mov  al, dl
ret


;***********************************************************************
;Get 1ST Mouse Byte
;***********************************************************************
GETFIRST:
  call GETB 		;Get byte1 of packet
  xor  ah, ah
  mov  bl, al
  and  bl, 1
  mov  BYTE [LBUTTON], bl
  mov  bl, al
  and  bl, 2
  shr  bl, 1
  mov  BYTE [RBUTTON], bl
  mov  bl, al
  and  bl, 4
  shr  bl, 2
  mov  BYTE [MBUTTON], bl
  mov  bl, al
  and  bl, 16
  shr  bl, 4
  mov  BYTE [XCOORDN], bl
  mov  bl, al
  and  bl, 32
  shr  bl, 5
  mov  BYTE [YCOORDN], bl
  mov  bl, al
  and  bl, 64
  shr  bl, 6
  mov  BYTE [XFLOW], bl
  mov  bl, al
  and  bl, 128
  shr  bl, 7
  mov  BYTE [YFLOW], bl
ret


;***********************************************************************
;Get 2ND Mouse Byte
;***********************************************************************
GETSECOND:
  call GETB 		;Get byte2 of packet
  xor  ah, ah
  mov  BYTE [XCOORD], al
ret


;***********************************************************************
;Get 3RD Mouse Byte
;***********************************************************************
GETTHIRD:
  call GETB 		;Get byte3 of packet
  xor  ah, ah
  mov  BYTE [YCOORD], al
ret



;-----------------------------------------------------------------------
;***********************************************************************
;* MAIN PROGRAM
;***********************************************************************
;-----------------------------------------------------------------------


MAINP:
  call PS2SET
  call ACTMOUS
  call GETB 	;Get the responce byte of the mouse (like: Hey i am active)  If the bytes are mixed up, remove this line or add another of this line.
  call GETB
  ret

mousemain:
  call GETFIRST
  call GETSECOND
  call GETTHIRD

;*NOW WE HAVE XCOORD & YCOORD* + the button status of L-butten and R-button and M-button allsow overflow + sign bits

;!!!
;! The Sign bit of X tells if the XCOORD is Negative or positive. (if 1 this means -256)
;! The XCOORD is allways positive
;!!!

;???
;? Like if:    X-Signbit = 1		Signbit
;? 					|
;?             XCOORD = 11111110 ---> -256 + 254 = -2  (the mouse cursor goes left)
;?                      \      /
;?                       \    /
;?                        \Positive
;???


;?? FOR MORE INFORMATION ON THE PS/2 PROTOCOL SEE BELOW!!!!



;!!!!!!!!!!!!!
;the rest of the source... (like move cursor) (i leave this up to you m8!)
;!!!!!!!!!!!!!


;*************************************************************
;Allright, Allright i'll give an example!  |EXAMPLE CODE|
;*************************************************************
;=============================
;**Mark a position on scr**
;=============================
 mov BYTE [row], 15
 mov BYTE [col], 0

;=============================
;**go to start position**
;=============================
 call GOTOXY

;=============================
;**Lets display the X coord**
;=============================
 mov  si, strcdx	; display the text for Xcoord
 call disp
 mov  al, BYTE [XCOORD]
 mov si, mousechangepos
 mov [si], al
 mov  al, BYTE [XCOORDN]
 mov si, mousechangesign
 mov [si], al
 or   al, al
 jz  .negative
 mov  si, strneg	; if the sign bit is 1 then display - sign
 call disp
 jmp .positive
.negative
 mov  si, strsp		; else display a space
 call disp
.positive
 xor  ah, ah
 mov  al, BYTE [XCOORD]
 call DISPDEC
 mov  si, stretr	; goto nextline on scr
 call disp

;=============================
;**Lets display the Y coord**
;=============================
 mov  si, strcdy	; display the text for Ycoord
 call disp
 mov  al, BYTE [YCOORD]
 mov si, mousechangepos
 inc si
 mov [si], al
 mov  al, BYTE [YCOORDN]
 mov si, mousechangesign
 inc si
 mov [si], al
 or   al, al
 jz  .negativex
 mov  si, strneg	; if the sign bit is 1 then display - sign
 call disp
 jmp .positivex
.negativex
 mov  si, strsp		; else display a space
 call disp
.positivex
 xor  ah, ah
 mov  al, BYTE [YCOORD]
 call DISPDEC
 mov  si, stretr	; goto nextline on scr
 call disp

call showcursor
;=============================
;**Lets display the L button**
;=============================
 mov  si, strlbt	; display the text for Lbutton
 call disp
 mov  al, BYTE [LBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, stretr	; goto nextline on scr
 call disp

;=============================
;**Lets display the R button**
;=============================
 mov  si, strrbt	; display the text for Rbutton
 call disp
 mov  al, BYTE [RBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, stretr	; goto nextline on scr
 call disp
 
;=============================
;**Lets display the M button**
;=============================
 mov  si, strmbt	; display the text for Mbutton
 call disp
 mov  al, BYTE [MBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, stretr	; goto nextline on scr
 call disp

ret

newmousecursor:
	add dl, dl
	mov si, lastmousepos
	mov cx, dx
	add dl, [si]
	inc si
	mov al, 0
	sub al, dh
	mov dh, al
	add dh, [si]
	dec si
	cmp dl, 208
	jbe nooriginx
	mov dl, 0
nooriginx:
	cmp dh, 208
	jbe nooriginy
	mov dh, 0
nooriginy:
	cmp dl, 158
	jbe nofixxcolumn
	mov dl, 158
nofixxcolumn:
	cmp dh, 23
	jbe nofixyrow
	mov dh, 23
nofixyrow:
	mov [si], dx
	inc si
	jmp donecheckmousesign

showcursor:
	mov [dxcache2],dx
	mov si, mousechangepos
	mov dx, [si]
	jmp newmousecursor
donecheckmousesign:
	dec si
	mov dx, [si]
	mov si, lastmousepos
	mov [si], dx
	mov si, mousechangepos
	mov word [si], 0
	mov si, mousechangesign
	mov word [si], 0
	mov al, 1
	mov bl, 7
	call int30hah9dr
	mov dx, [dxcache2]
	ret

clearmousecursor:
	mov [dxcache2], dx
	mov si, lastmousepos
	mov dx, [si]
	mov al, 0
	call int30hah9dr
	mov dx, [dxcache2]
	ret



quitprog:
 call clear
 jmp nwcmd		
;-----------------------------------------------------------------------
;***********************************************************************
;* END OF MAIN PROGRAM
;***********************************************************************
;-----------------------------------------------------------------------


lastmousepos db 10,10
mousechangepos db 0,0
mousechangesign db 0,0








;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;X Dont Worry about this displaypart, its yust ripped of my os.
;X (I know it could be done nicer but this works :P)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXX
;************************************************
;* Displays AX in a decimal way 
;************************************************
dxcache2 db 0,0
DISPDEC:
	ret
	mov [dxcache2],dx
    mov  BYTE [zerow], 0x00
    mov  WORD [varbuff], ax
    xor  ax, ax
    xor  cx, cx
    xor  dx, dx
    mov  bx, 10000
    mov  WORD [deel], bx
   .mainl    
    mov  bx, WORD [deel]
    mov  ax, WORD [varbuff]
    xor  dx, dx
    xor  cx, cx
    div  bx
    mov  WORD [varbuff], dx
    jmp .ydisp
   
   .vdisp
    cmp  BYTE [zerow], 0x00
    je .nodisp

   .ydisp
    add  al, 48                              ; lets make it a 0123456789 :D
    mov  bx, 1 
	mov dx, [dxcache2]
call int30hah6
	mov [dxcache2],dx
    mov  BYTE [zerow], 0x01
   jmp .yydis

   .nodisp

   .yydis
    xor  dx, dx
    xor  cx, cx
    xor  bx, bx
    mov  ax, WORD [deel]
    cmp  ax, 1
    je .bver
    cmp  ax, 0
    je .bver
    mov  bx, 10
    div  bx
    mov  WORD [deel], ax
   jmp .mainl

   .bver
   ret
;***************END of PROCEDURE*********************************
;****************************************************************
;* PROCEDURE disp      
;* display a string at ds:si via BIOS
;****************************************************************
disp:
	ret
 .HEAD
    mov  bx, 1 				     ; make it a nice fluffy blue (mostly it will be grey but ok..)
	mov ax, 0
	mov dx, [dxcache2]
        call int30hah1
 	mov [dxcache2],dx
 .DONE: 
   ret
;*******************End Procedure ***********************
;*****************************
;*GOTOXY  go back to startpos
;*****************************
GOTOXY:
	call clearmousecursor
	ret
    mov ah, 2
    mov bh, 0                  ;0:graphic mode 0-3: in modes 2&3 0-7: in modes 0&1
	mov dx, [dxcache2]
    mov dl, BYTE [col]
    mov dh, BYTE [row]
    mov si, blank2
    mov al, 0
    call int30hah1
	mov [dxcache2],dx
ret
;*******END********
;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX








;***********************************************************************
;variables
;***********************************************************************
blank2	db 10,0
LBUTTON db 0x00	;	Left   button status 1=PRESSED 0=RELEASED
RBUTTON db 0x00	;	Right  button status 1=PRESSED 0=RELEASED
MBUTTON db 0x00	;	Middle button status 1=PRESSED 0=RELEASED
XCOORD  db 0x00	;	the moved distance  (horizontal)
YCOORD  db 0x00	;	the moved distance  (vertical)
XCOORDN db 0x00 ;       Sign bit (positive/negative) of X Coord
YCOORDN db 0x00 ;       Sign bit (positive/negative) of Y Coord
XFLOW   db 0x00 ;       Overflow bit (Movement too fast) of X Coord
YFLOW   db 0x00 ;       Overflow bit (Movement too fast) of Y Coord







;************************************
;* Some var's of my display function
;************************************
deel    dw 0x0000
varbuff dw 0x0000
zerow   db 0x00
strlbt  db "Left button:   ", 0x00
strrbt  db "Right button:  ", 0x00
strmbt  db "Middle button: ", 0x00
strcdx  db "Mouse moved (X): ", 0x00
strcdy  db "Mouse moved (Y): ", 0x00
stretr  db 0x0D, 0x0A, 0x00
strneg  db "-", 0x00
strsp   db " ", 0x00
row     db 0x00
col     db 0x00
MOUSEON db 0


;***********************************************************************
; PS/2 mouse protocol (Standard PS/2 protocol)
;***********************************************************************
; ----------------------------------------------------------------------
;
; Data packet format: 
; Data packet is 3 byte packet. 
; It is send to the computer every time mouse state changes 
; (mouse moves or keys are pressed/released). 
; 
;   Bit7 Bit6 Bit5 Bit4 Bit3 Bit2 Bit1 Bit0 
; 
; 1. YO   XO   YS   XS   1    MB   RB   LB 
; 2. X7   X6   X5   X4   X3   X2   X1   X0
; 3. Y7   Y6   Y5   Y4   Y3   Y2   Y1   Y0
;
; This means:
; YO   :  Overflow bit for Y-coord (movement to fast)
; XO   :  Overflow bit for X-coord (movement to fast) 
; X0-X7:  byte of the x-coord 
; Y0-Y7:  byte of the y-coord
; LB   :  Left button pressed
; RB   :  Right button pressed
; MB   :  Middle button pressed
;
;*********************************************************************** 
;If you want to use the scroll function u might look up the protocol at 
;the company that made the mouse. 
;(the packet format will then mostly be greater then 3)
;***********************************************************************
