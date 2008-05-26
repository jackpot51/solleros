;MODEL SMALL,C
.CODE

	mov     ax,12h
	int     10h

	mov     dl,1
	mov     ax,0
	mov     bx,0
	mov     si,100
	mov     di,100

	call    DRAWLINE

	mov     ah,4ch
	int     21h

;PUBLIC DRAWLINE
;---------------------------------------------------
; VGAPIXEL - Draws a pixel in mode 12h
;            Uses write mode 2
;            AX = X
;            BX = Y
;            DL = COLOR
;            ES MUST be 0A000h
;---------------------------------------------------

VGAPIXEL	;PROC

	MOV     CL,4            ; Calculate offset in BX
	SHL     BX,CL           ; (Offset=(Y*80)+(X/8)
	MOV     CX,BX
	SHL     BX,2
	ADD     BX,CX
	MOV     CX,AX
	SHR     CX,3
	ADD     BX,CX


	AND     AX,7            ; Calculate Mask
	MOV     CL,AL
	MOV     AH,80h
	SHR     AH,CL
	MOV     AL,8            ; Write mask to port 3CEh function 8

	PUSH    DX
	MOV     DX,3CEh
	OUT     DX,AX
	POP     DX

	MOV     AL,[GS:BX]     ; Read data into latch
	MOV     byte [GS:BX], dl     ; Write pixel
	RET

;VGAPIXEL        ENDP

;--------------------------------------------
; Variables for Breshenham's Linedraw routine
;--------------------------------------------
COLOR   DB 1
X1      DW 0
Y1      DW 0
X2      DW 0
Y2      DW 0
DIFFX   DW 0
DIFFY   DW 0
DELT1   DW 0
DELT2   DW 0
DELT3   DW 0
DELT4   DW 0
ZX1	DW 0
ZX2	DW 0
ZY1	DW 0
ZY2	DW 0
ZCOLOR  DB 0
FLIPPED DB 0

;-----------------------------------
; DRAW_THE_LINE - Breshenham's linedraw
;                 X1 = AX
;                 Y1 = BX
;                 X2 = SI
;                 Y2 = DI
;                 COLOR = DL
;-----------------------------------

DRAWLINE   ;PROC zx1,zy1,zx2,zy2,zcolor

	;PUSH    SI
	;PUSH    DI
	;PUSH    DS
	;PUSH    ES


	MOV     AX,[ZX1]
	MOV     BX,[ZY1]
	MOV     SI,[ZX2]
	MOV     DI,[ZY2]
	MOV     DX,[ZCOLOR]

	MOV     byte [FLIPPED],0

	MOV     [COLOR],DL
	MOV     [X1],AX
	MOV     [Y1],BX
	SUB     AX,SI
	CWD
	XOR     AX,DX
	SUB     AX,DX
	MOV     [DIFFX],AX
	MOV     AX,BX
	SUB     AX,DI
	CWD
	XOR     AX,DX
	SUB     AX,DX
	MOV     [DIFFY],AX
	CMP     AX,[DIFFX]
	JLE     NOFLIP
	MOV     byte [FLIPPED],1
	MOV     [DIFFX],AX
	MOV     AX,[X1]
	MOV     BX,[Y1]
	MOV     [X1],BX
	MOV     [Y1],AX
	MOV     AX,SI
	MOV     SI,DI
	MOV     DI,AX
NOFLIP:
	MOV     [X2],SI
	MOV     [Y2],DI
	MOV     AX,[X1]
	CMP     AX,[X2]
	JLE     NOFLIP2
	MOV     AX,[Y2]
	MOV     BX,[Y1]
	MOV     [Y1],AX
	MOV     [Y2],BX
	MOV     AX,[X2]
	MOV     BX,[X1]
	MOV     [X2],BX
	MOV     [X1],AX
NOFLIP2:
	MOV     AX,[Y2]
	SUB     AX,[Y1]
	MOV     [DIFFY],AX
	SHL     AX,1
	MOV     [DELT2],AX
	SUB     AX,[DIFFX]
	MOV     [DELT1],AX
	MOV     AX,[DIFFY]
	SUB     AX,[DIFFX]
	SHL     AX,1
	MOV     [DELT3],AX
	MOV     AX,[DIFFY]
	ADD     AX,[DIFFX]
	SHL     AX,1
	MOV     [DELT4],AX
LINELP:
	CMP     byte [FLIPPED],0
	JNE     NO_FLIP3
	MOV     AX,[X1]
	MOV     BX,[Y1]
	JMP     SHORT DL1
NO_FLIP3:
	MOV     AX,[Y1]
	MOV     BX,[X1]
DL1:
	MOV     DL,[COLOR]

	CALL    VGAPIXEL                ; Bytt dette ut med din


	MOV     AX,[X1]
	CMP     AX,[X2]
	JGE     DLDONE
	INC     word [X1]
	CMP     word [DELT1],0
	JGE     DL2
	CMP     word [DIFFY],0
	JGE     DL3
	DEC     word [Y1]
	MOV     AX,[DELT4]
	JMP     SHORT DL4
DL2:
	CMP     word [DIFFY],0
	JLE     DL3
	INC     word [Y1]
	MOV     AX,[DELT3]
	JMP     SHORT DL4
DL3:
	MOV     AX,[DELT2]
DL4:
	ADD     [DELT1],AX
	JMP     SHORT LINELP
DLDONE:
	;POP     ES
	;POP     DS
	;POP     DI
	;POP     SI

	RET
;DRAWLINE   ENDP

