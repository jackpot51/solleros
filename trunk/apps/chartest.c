#include <stdio.h>
#include <errno.h>
#include <sys/time.h>
struct timeval begin, end;

void main(int argc, char *argv[]){
	if(argc==2){
		int number = atoi(argv[1]);
		int i;
		if(number==0){
			errno=EINVAL;
			perror("The number must be larger than 0.");
		}else{
			gettimeofday(&begin, NULL);
			char c = ' ';
			for(i=1;i<=number;i++){
				printf("%c",c);
				c++;//lol
				if(c=='~'){
					c=' ';
				}
			}
			gettimeofday(&end, NULL);
			int uduration = (end.tv_sec - begin.tv_sec)*1000000 + end.tv_usec - begin.tv_usec;
			float duration = (float)(uduration)/1000000;
			printf("\nPrinted %d characters in %f seconds.\n", number, duration);
			float speed = (float)(number)/duration;
			printf("This is at a rate of %f characters per second.\n",speed);
		}
	}else{
		errno=EINVAL;
		perror("You must supply a single number as the command argument");
	}
	
}
