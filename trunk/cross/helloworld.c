#include <stdio.h>
#include <time.h>
void main(){
	printf("Hello world!\n");
	time_t begin;
	time(&begin);
	printf("UTC time is now %s", ctime(&begin));
	char n[256];
	printf("Type something\n");
	scanf("%s", &n);
	printf("You typed \"%s\"\n",n);
	char s = n[0];
	if(n[0]==8){
		s=27;
	}
	if(n[0]==13){
		s=25;
	}
	time_t end;
	time(&end);
	printf("It took you %d seconds to type that.\n", end - begin);
	printf("The first key was %d in decimal, 0x%x in hex, and \"%c\" in ASCII\n", n[0], n[0], s);
	printf("Goodbye world!\n");
}
