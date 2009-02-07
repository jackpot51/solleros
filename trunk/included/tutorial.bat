clear
echo The batch program can run all commands featured in SollerOS.
echo It can also run the extra "if" command.
echo Would you like a tour of the SollerOS system?
echo If so, you can type yes and press enter.
$a=
if $a=no
echo Fine then.
stop
fi
if $a=yes
clear
ls
echo Press any key to continue.
wait
clear
echo ls and dir-these show all available programs
echo menu-this returns to the boot menu
echo uname-this shows the system build
echo help-this shows the nonexistant help file
echo logout-this logs the user out
echo clear-this clears the screen
echo echo-this prints text and variables to the screen
echo runbatch-this runs batch files
echo showbatch-this shows the currently loaded batch file
echo batch-this creates a new batchfile
echo #-this evaluates expresions
echo %-this gives back the last answer
echo the $ sign is used for variables
fi