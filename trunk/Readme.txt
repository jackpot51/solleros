Simply edit the bash/batch script to point to your SVN checkout directory and run it to build an image. Use dd to copy that image to a floppy and you're good to go.
ex. 
	dd if=SollerOS.bin of=/dev/floppy bs=512 ; use this for linux

	dd if=SollerOS.bin of=\\?\Device\Floppy0 bs=512 ; use this for windows