[map symbols build/kernel.map]
%include "config.asm"
[BITS 16]
    %include "source/boot.asm"
    %include "source/pmode.asm"
	%include "source/realmode.asm"
[BITS 32]
    %include "source/exception.asm"
    %include "source/ints.asm"
    %include "source/dosints.asm"
    %include "source/solleros.asm"
    %include "source/programs.asm"
	%include "source/hardware.asm"
    %include "source/pci.asm"
    %include "source/disk.asm"
    %include "source/threads.asm"
%ifdef gui.included
    %include "source/gui/gui.asm"
%endif
    %include "source/data.asm"
    %include "build/fileindex.asm"
    %include "source/bss.asm"
    %include "build/files.asm"
