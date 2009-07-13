;;for paging, translation, etc.
memorytest:
	call enablepaging
	jmp $
enablepaging:
	mov eax, ospagedir
	mov cr3, eax
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax
	ret
	
getmem:		;;call with size in ecx
			;;returns with available size in ecx, location in esi
mov esi, ospagedir
add esi, [pagepointer]

pagepointer dd 0