;These flags are used to configure options as on, put a simicolon in front of it to not configure it

;%define gui.included
;Turn on the gui

;%define io.serial
;Use the serial port for input and output instead of the keyboard and screen
;If the gui is included this should not be enabled

%define threads.included
;Include the thread testing stuff-this uses a relatively large amount of memory

%define exceptions.included
;Display debugging information should crashes occur-also uses quite a bit of memory

;%define disk.protected
;Use protected mode instead of real mode for disk access

%define disk.real
;Use real mode for disk access

;%define sound.included
;This includes the sound drivers

%define rtl8139.included
;This includes the RTL8139 drivers

;%define sector.debug
;Dump the contents of the first sector of SollerOS

;FIX DEPENDANCIES
%ifdef gui.included
%undef io.serial
%endif
%ifdef disk.protected
%undef disk.real
%endif
