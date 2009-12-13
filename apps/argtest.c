#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]){
	printf("The command that was run is \"%s\"\n", argv[0]);
	if((argc)==2){
		printf("There is 1 command parameter.\n");
	}
	else{
		printf("There are %d command parameters.\n", argc - 1);
	}
	int i;
	for(i=1;i<argc;i++){
			printf("Parameter %d is \"%s\"\n", i, argv[i]);
	}
	return 0;
}
