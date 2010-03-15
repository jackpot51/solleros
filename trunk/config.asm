;These flags are used to configure options as on, put a simicolon in front of it to not configure it

%define gui.included
;Turn on the gui

;%define gui.alphablending
;Make the terminal in the GUI 25% transparent

%define gui.background
;Make the GUI have a loadable background

;%define gui.time
;Show time in top right corner of screen

;%define io.serial "1"
;Use the specified serial port for input and output instead of the keyboard and screen
;If the gui is included this should not be enabled

;%define terminal.vsync
;Uses the RTC to automatically update the terminal at ~64Hz
	;WARNING:
	;This may cause problems on systems with non-standard RTC's
	;It is therefore recommended that you do not enable it even
	;though it gives a large speed improvement for character output

%define hardware.automatic
;Automatically load the sound and network drivers.

%define threads.included
;Include the thread testing stuff-this uses a relatively large amount of memory

%define exceptions.included
;Display debugging information should crashes occur-also uses quite a bit of memory

;%define disk.protected
;Use protected mode instead of real mode for disk access-this allows for multitasking

%define disk.real
;Use real mode for disk access-this gives greater compatibility

%define sound.included
;This includes the sound drivers

%define network.included
;This includes the network stack\

%define rtl8169.included
;This includes the RTL8169 drivers

%define rtl8139.included
;This includes the RTL8139 drivers

%define ne2000.included
;This includes the ne2000 drivers

%define i8254x.included
;This includes the Intel 8254x drivers

;%define sector.debug
;Dump the contents of the first sector of SollerOS

;%define system.simple 
;The smallest possible system, overrides all options

;FIX DEPENDANCIES
%ifdef gui.included
	%undef io.serial
%else
	%undef gui.alphablending
	%undef gui.background
%endif
%ifdef disk.protected
	%undef disk.real
%endif
%ifdef network.included
%else
	%undef i8254x.included
	%undef ne2000.included
	%undef rtl8139.included
	%undef rtl8169.included
%endif
%ifdef system.simple
	%define io.serial "1"
	%define disk.real
	%undef gui.included
	%undef gui.alphablending
	%undef gui.background
	%undef terminal.vsync
	%undef hardware.automatic
	%undef threads.included
	%undef exceptions.included
	%undef disk.protected
	%undef sound.included
	%undef network.included
	%undef rtl8139.included
	%undef rtl8169.included
	%undef ne2000.included
	%undef i8254x.included
	%undef sector.debug
%endif
