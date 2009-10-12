#include <stdio.h>
void main(){
	printf("Hello world!\r\n");
	int n = 0;
	scanf("%c", &n);
	printf("The ASCII output of that key is 0x%x in hex, %d in decimal, and \"%c\" in ASCII.\r\n", n, n, n);
	printf("Goodbye world!\r\n");
}
