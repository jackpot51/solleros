### Building ###
  1. Open a terminal and cd to the svn trunk/cross.
  1. Run the firstbuild.sh script as root.
### Using The Easy Way ###
  1. Make a .c file in the apps directory.
  1. Run the run.sh script in the svn trunk.
  1. Login to SollerOS
  1. Run ./(name of the .c file).elf
### Using The Hard Way ###
  1. Make a .c file.
  1. Run "/SollerOS/cross/bin/i586-pc-solleros-gcc (name of the .c file) -o (name of the output executable)" or run "./cross (name of the .c file)"
  1. Copy the output file to the svn trunk/included
  1. Run the run.sh script in the svn trunk
  1. Login to SollerOS
  1. Run ./(name of the executable)