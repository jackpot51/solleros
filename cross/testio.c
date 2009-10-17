#include <stdio.h>
#include <string.h>
void main(int argc, char *argv[]){
	printf("Press a key.\n");
	char c[2];
	int n =testread(0,&c,1);
	printf("\nYou pressed \'%c\'.\n",c[0]);
	printf("What is your name?\n");
	char test[20];
	n=testread(0,&test,20);
	printf("Read %d characters out of the function.\n", n);
	n=testwrite(1,&test,20);
	printf("\nWrote %d characters using the function.\n", n);
	printf("Got \"%s\" out of the function.\n",test);
	if(argc>1){
		printf("\"%s\" recieved \"%s\" as an argument.\n",argv[0],argv[1]);
		if(!strcmp(argv[1], test)){
			printf("The string was equal to the given argument.\n");
		}else{
			perror("The string was not equal to the given argument.\n");
		}
	}
}
int testwrite(int file, char *ptr, int len){
		int i;
		if(file==1 || file == 2){
			char old = ptr[len];
			ptr[len]='\0';
	        asm("movb $1, %%ah\n\t"
				"movb $0, %%al\n\t"
				"movb $7, %%bl\n\t"
				"int $0x30"
				: "=c" (i)
				: "S" (ptr)
				: "%eax", "%edi", "%ebx", "%edx"
				);
			ptr[len]=old;
		}
        return i;
}
int testread(int file, char *ptr, int len){
		int i = 0;
		if(file==0){
			    asm("movb $4, %%ah\n\t"
					"movb $10, %%al\n\t"
					"movb $7, %%bl\n\t"
					"int $0x30"
					: "=c" (i)
					: "S" (ptr), "D" (ptr + len)
					: "%eax", "%ebx", "%edx"
					);
		}
		return i;
}
