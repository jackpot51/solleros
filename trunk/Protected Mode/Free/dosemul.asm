;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Setup the Interrupt 21h
;; (Found code in internet)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dos:	MOV EAX, 0
	MOV AX, CS

	SHL EAX, 16			; 16 bit left shif of EAX
	MOV AX, int21h			; AX points the the code of the Interrupt
	XOR BX, BX			; BX = 0
	MOV FS, BX			; FS = BX = 0

	CLI				; Interrupt Flag clear
	MOV [FS:21h*4], EAX		; Write the position of the Interrupt code into
					; the interrupt table (index 21h)
	STI				; Interrupt Flag set
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Project 		: 	FDOS 0.0.9
;; Author 		: 	Stefan Tappertzhofen (tappertzhofen@t-online.de)
;; Webpage 		: 	http://www.fdos.de
;; Date 		: 	1.5.2004
;; Info		 	: 	DOS Interrupt
;; Filename 		: 	dos.asm
;; Compile Syntax 	: 	nasm dos.asm -f bin -o dos.sys
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Init:
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Get Function Reference Number stored in AH
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	; Function Call				Function Info			Supported
	; -------------				-------------			---------

	CMP AH, 0h
	JE NEAR int_dos_0h			; Shut down application 	(x)

	CMP AH, 1h
	JE NEAR int_dos_2h			; Get Char			(1/2)

	CMP AH, 2h
	JE NEAR int_dos_2h			; Print Char on screen		(x)

	CMP AH, 3h
	JE NEAR int_dos_3h			; Get Char from AUX		( )

	CMP AH, 4h
	JE NEAR int_dos_4h			; Send Char to AUX		( )

	CMP AH, 5h
	JE NEAR int_dos_5h			; Print Char with Printer	( )

	CMP AH, 9h
	JE NEAR int_dos_9h			; ASCI-$ String			(x)

	CMP AH, 4Ch				
	JE NEAR int_dos_4Ch			; Shut down application		(x)
	
	IRET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Interrupt Functions
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 0h
;;
;; Input: AH = 0
;; Output: n/a
;; Info: Shut down the application and get the FDOS Interrupt back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_0h:

	jmp nwcmd


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 1h
;;
;; Input: AH = 1h
;; Output: AL = Char
;; Info: Get Char by keyboard
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_1h:
	
	PUSH BX						; Push BX and DX
	PUSH DX

	XOR AH, AH					; Wait for Key Press
	INT 16h						; BIOS Interrupt 16h
	
	POP DX						; Get DX and BX back
	POP BX

	IRET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 2h
;;
;; Input: AH = 2, DL = ASCI Char to output
;; Output: n/a
;; Info: Shut down the application and get the FDOS Interrupt back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_2h:

	PUSHA						; Save all Registers

	MOV AL, DL					; Write Output Char to AL			
	MOV AH, 0x0E					; Print Char to Screen
	MOV BH, 0
	MOV BL, 7
	INT 10h						; Using BIOS Int 10h

	POPA
	
	CLC						; Clear Carry Flag		
	IRET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 0h
;;
;; Input: AH = 0
;; Output: n/a
;; Info: Shut down the application and get the FDOS Interrupt back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_3h:

	PUSH ES						; Save ES and DS
	PUSH DS

		MOV AX, 7620h				; Set Multi Kernel Var to
		MOV ES, AX				; ZERO (= FDOS Kernel)
		MOV DS, AX
		XOR AX, AX				; = 0
		MOV DI, AX				; Offset
		STOSW					; Write it
		STOSW


	POP DS						; Get DS and ES back
	POP ES
	CLC						; Clear Carry Flag
	IRET						; Return to FDOS Standart Kernel
	
	.hang:		

		JMP SHORT .hang

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 0h
;;
;; Input: AH = 0
;; Output: n/a
;; Info: Shut down the application and get the FDOS Interrupt back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_4h:

	PUSH ES						; Save ES and DS
	PUSH DS

		MOV AX, 7620h				; Set Multi Kernel Var to
		MOV ES, AX				; ZERO (= FDOS Kernel)
		MOV DS, AX	
		XOR AX, AX				; = 0
		MOV DI, AX				; Offset
		STOSW					; Write it
		STOSW


	POP DS						; Get DS and ES back
	POP ES
	CLC						; Clear Carry Flag
	IRET						; Return to FDOS Standart Kernel
	
	.hang:		

		JMP SHORT .hang

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 0h
;;
;; Input: AH = 0
;; Output: n/a
;; Info: Shut down the application and get the FDOS Interrupt back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_5h:

	PUSH ES						; Save ES and DS
	PUSH DS

		MOV AX, 7620h				; Set Multi Kernel Var to
		MOV ES, AX				; ZERO (= FDOS Kernel)
		MOV DS, AX
		XOR AX, AX				; = 0
		MOV DI, AX				; Offset
		STOSW					; Write it
		STOSW


	POP DS						; Get DS and ES back
	POP ES
	CLC						; Clear Carry Flag
	IRET						; Return to FDOS Standart Kernel
	
	.hang:		

		JMP SHORT .hang

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 9h
;;
;; Input: AH = 9h, DX = Offset of String
;; Output: screen
;; Info: Shut down the application and get the FDOS Interrupt back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_9h:

		PUSHA					; Save all Registers

		MOV SI, DX				; SI = Offset of String

		CLD

		int_dos_9h_loop:

			LODSB				; Load Value of SI into AL and
							; increment SI
			CMP AL, '$'			; AL = $?
			JE SHORT int_dos_9h_done	; Yes yes then terminate function
			MOV AH, 0x0E			; Print Char to Screen
			MOV BH, 0
			MOV BL, 7
			INT 10h				; Using BIOS INT 10h
			JMP SHORT int_dos_9h_loop	; Next Loop
		
		int_dos_9h_done:
			
			POPA				; Get all Registers back
			IRET				; Exit function

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; DOS Int 21h, Function 4Ch
;;
;; Input: AH = 4Ch
;; Output: n/a
;; Info: Shut down the application and get the FDOS Interrupt back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_dos_4Ch:
	CLC
	call clear
	jmp nwcmd						; Return to FDOS Standart Kernel
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; INTERRUPT 21H
;; (by Stefan Tappertzhofen)
;;
;; Function number stored in AH
;; See Function infos for details
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int21h:

		jmp Init