clear
echo Would you like a tour of the SollerOS system?
echo If so, you can type yes and press enter.
$a=
if $a=no
echo Fine then.
stop
fi
if $a=yes
clear
echo These are the available commands.
ls
echo Press any key to continue.
wait
clear
echo This is the content of the filesystem
disk
echo Press any key to continue.
wait
clear
echo ls and dir show all available programs
echo disk shows files on the disk
echo clear clears the screen
echo wait waits for a keypress
echo echo prints text and variables to the screen
echo logout logs the user out
echo # evaluates expresions
echo % gives back the last answer from #
echo the dollar sign is used to denote and set variables
echo ./ runs batch files and programs
echo while, if, else, loop, and fi are used in batch files
echo they use the syntax if $var=$var, else, fi
echo and while $var=$var, loop
echo stop is used to exit the batch before the end
echo pci shows a list of information about pci devices
echo batch creates a new batch file
echo show shows text files and batch files
echo dump dumps a location in memory
echo time shows the current system time
echo cpuid shows information about the cpu
fi