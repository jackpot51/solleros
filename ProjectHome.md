### Testers ###
Please read the content in the Wiki section. Information about assembling and running SollerOS, usernames, passwords, interrupts, and keymaps are all there.
I just added an interesting feature. If you go to http://solleros.googlecode.com/svn/trunk/jpc.html you can run SollerOS in a browser window.

### Current Events ###
#### THE NEXT UPLOADED MAJOR BUILD ####
You should expect many BIG fixes. There will be lots of code cleanup and I will try to get UnFS rolled into the main kernel which means that filesystem reads and writes will be much easier.
#### Cross Compiler ####
The GCC cross compiler is working. File access will be added later.
#### Sound ####
Sound! Proper sound management using the PC Speaker or a Soundblaster card has been added. I will document the sound system when it matures.
#### Unicode ####
UTF-8 support is included by default.
#### UnFS ####
I am now working on a new filesystem for SollerOS which will be called UnFS (Unlimited File System). I will probably write a paper on it's design and features so check in the wiki section for more updates in the next few days.

### Introduction ###
This is an operating system created by Jeremy Soller which uses 99% original code and some code from other open source operating systems. It is currently buggy and unfinished but will continue to improve as time goes on.

### Goal ###
The goal of this project is to create an entire operating system, from the kernel to modules to programming languages, in strictly assembly code. This will ensure that this operating system is as fast as possible (it should be MUCH faster) when compared with other operating systems that are mainly programed in C.

### What has been done ###
  * Protected mode has finally been completed and all functions have been, albeit horribly, converted to the new system
  * Batch files can be created and loaded using variables, loops, nested if-else commands, etc.
  * Did I mention user variables?
  * System can be loaded in milliseconds to a usable state
  * Mouse support
  * A GUI using VESA
  * And more stuff that I forgot that I added.

### What will be done in the near future ###
  * Multitasking
  * Mediocre device driver system
  * Any suggestions would be great

### What will be done eventually ###
  * Windowing system
  * Networking
  * And everything else imaginable

### To anyone dum enough to install my unstable operating system ###
In Soviet Russia, SollerOS bugtests you!