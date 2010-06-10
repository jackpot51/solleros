#!/bin/shush
clear
echo Would you like a tour of the SollerOS system?
echo If so, you can type yes and press enter.
$a=
if yes=$a
clear
echo These are the available commands.
help
echo Press any key to continue.
wait
clear
echo This is the content of the filesystem
ls
echo Press any key to continue.
wait
clear
echo help	shows all available programs
echo ls	shows files on the disk
echo clear	clears the screen
echo wait	waits for a keypress
echo echo	prints text and variables to the screen
echo logout	logs the user out
echo !	evaluates expresions
echo %	gives back the last answer from !
# shush replaces ## with # and $$ with $
# $ followed by anything else is replaced with the variable, provided it exists
# # followed by anything else is quiet
echo ##	is used for comments
echo $$	is used to denote and set variables
echo ./	runs batch files and programs
echo exit	is used to exit the batch before the end
echo pci	shows a list of information about pci devices
echo batch	creates a new batch file
echo show	shows text files and batch files
echo dump	dumps a location in memory
echo time	shows the current system time
echo cpuid	shows information about the cpu
echo system	shows system information
echo while, if, else, loop, and fi are used in batch files
echo they use the syntax if var=var, else, fi
echo and while var=var, loop
else
echo Fine then.
fi