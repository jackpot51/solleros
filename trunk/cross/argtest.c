#include <stdio.h>
#include <string.h>

void main(int argc, char *argv[]){
	printf("There are %d command parameters.\r\n", argc);
	printf("The command that was run is \"%s\"\r\n", argv[0]);
	if(argc>1){
			printf("The first parameter is \"%s\"\r\n", argv[1]);
	}
	if(argc>2){
			printf("The second parameter is \"%s\"\r\n", argv[2]);
	}
}
