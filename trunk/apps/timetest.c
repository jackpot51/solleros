#include <stdio.h>
#include <sys/time.h>
struct timeval begin, end;
int main(int argc, char *argv[]){
	printf("Finding the smallest measurable time interval.\n");
	gettimeofday(&begin, NULL);
	end = begin;
	int i,num;
	num = 1;
	while((end.tv_usec - begin.tv_usec) == 0){
		gettimeofday(&begin, NULL);
		for(i=0;i<num;i++){
		    printf("\r%d",num);
		}
		gettimeofday(&end, NULL);
		num++;
	}
	printf("\nThe smallest time interval is %d microseconds.\n", end.tv_usec - begin.tv_usec);
	return 0;
}