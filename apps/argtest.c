#include <stdio.h>
#include <string.h>

void main(int argc, char *argv[]){
	printf("The command that was run is \"%s\"\n", argv[0]);
	printf("There are %d command parameters.\n", argc);
	int i;
	for(i=1;i<argc;i++){
			printf("Parameter %d is \"%s\"\n", i, argv[i]);
	}
}
