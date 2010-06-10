[map symbols build/kernel.map]
%include "config.asm"
[ORG 0x100]
	%include "source/signature.asm"
	dd bsscopy - header ;size of kernel data on disk
[BITS 16]
    %include "source/boot.asm"
    %include "source/pmode.asm"
	%include "source/realmode.asm"
[BITS 32]
    %include "source/exception.asm"
    %include "source/ints.asm"
    %include "source/dosints.asm"
    %include "source/shush.asm"
    %include "source/programs.asm"
	%include "source/hardware.asm"
    %include "source/pci.asm"
    %include "source/disk.asm"
    %include "source/threads.asm"
%ifdef gui.included
    %include "source/gui/gui.asm"
%endif
%ifdef network.included
	%include "source/network.asm"
%endif
    %include "source/data.asm"
%ifdef disk.none
	diskfileindex:
	enddiskfileindex:
    %include "source/bss.asm"
%else
    %include "build/fileindex.asm"
    %include "source/bss.asm"
    %include "build/files.asm"
%endif
