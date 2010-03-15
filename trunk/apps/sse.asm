%include "include.inc"
PRINT "Showing debug registers.",10
mov ecx, dr0
call showhex
mov ecx, dr1
call showhex
mov ecx, dr2
call showhex
mov ecx, dr3
call showhex
mov ecx, dr6
call showhex
mov ecx, dr7
call showhex
PRINT 10,"Filling memory using normal registers.",10
hlt
call stime
call fillnorm
call etime
PRINT "nanoseconds.",10,"Using SSE to clear memory.",10
hlt
call stime
call clearsse
call etime
PRINT "nanoseconds.",10,"Filling memory using SSE.",10
hlt
call stime
call fillsse
call etime
PRINT "nanoseconds.",10,"Clearing memory using normal registers.",10
hlt
call stime
call clearnorm
call etime
PRINT "nanoseconds.",10
hlt
xor ebx, ebx
jmp exit

stime:
	mov ah, 12
	int 0x30
	mov [previouss], eax
	mov [previousns], ebx
	ret

etime:
	mov ah, 12
	int 0x30
	mov ecx, [previouss]
	mov edx, [previousns]
	sub eax, ecx
	cmp ebx, edx
	ja .nofix
.lp:
	add ebx, 1000000000
	dec eax
	cmp eax, 0
	jne .lp
.nofix:
	sub ebx, edx
	mov ecx, ebx
	call showdec
	ret

fillsse:
	movdqa xmm0, [pattern]
	mov esi, clearme
	jmp sse.lp
clearsse:
	pxor xmm0, xmm0
	mov esi, clearme
sse.lp:
	shr esi, 3
	shl esi, 3
	movdqa [esi], xmm0
	add esi, 16
	cmp esi, clearmeend
	jb sse.lp
	ret

fillnorm:
	mov eax, [pattern]
	mov esi, clearme
	jmp norm.lp
clearnorm:
	xor eax, eax
	mov esi, clearme
norm.lp:
	mov [esi], eax
	add esi, 4
	cmp esi, clearmeend
	jb norm.lp
	ret

previouss dd 0
previousns dd 0
align 16, nop
pattern times 4 dd 0xFFFFFFFF
align 16, nop
[section .bss]
clearme: resb 16*1024*1024*4 ;clear an entire 64 megabytes
clearmeend:
