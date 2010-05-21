#include <stdio.h>
#include <time.h>	
int UnixtoUTC(int t){
	int d = t/86400 + 1;
	int s = t%86400;
	int y = 1970;
	while(d>365){
		if(y%4==0) d-=366;
		else d-=365;
		y++;
	}
	int m = 1;
	if(d>=31){
		d-=31;
		m++;
	}
	if(d>=28 & y%4!=0){
		d-=28;
		m++;
	}
	if(d>=29 & y%4==0){
		d-=29;
		m++;
	}
	if(d>=31){
		d-=31;
		m++;
	}
	if(d>=30){
		d-=30;
		m++;
	}
	if(d>=31){
		d-=31;
		m++;
	}
	if(d>=30){
		d-=30;
		m++;
	}
	if(d>=31){
		d-=31;
		m++;
	}
	if(d>=31){
		d-=31;
		m++;
	}
	if(d>=30){
		d-=30;
		m++;
	}
	if(d>=31){
		d-=31;
		m++;
	}
	if(d>=30){
		d-=30;
		m++;
	}
	if(d>=31){
		d-=31;
		m++;
	}
	int h = s/3600;
	s = s%3600;
	int n = s/60;
	s = s%60;
	printf("Unix to UTC TIME:%d YEAR:%d MONTH:%d DAY:%d HOUR:%d MINUTE:%d SECOND:%d\n",t,y,m,d,h,n,s);
	return 0;
}
int UTCtoUnix(int y, int m, int d, int h, int n, int s){
	int t = 0;
	int m1 = m;
	int d1 = d;
	m--;
	d--;
	if(m>=1){
		d+=31;
		m--;
	}
	if(m>=1 & y%4==0){
		d+=29;
		m--;
	}
	if(m>=1 & y%4!=0){
		d+=28;
		m--;
	}
	if(m>=1){
		d+=31;
		m--;
	}
	if(m>=1){
		d+=30;
		m--;
	}
	if(m>=1){
		d+=31;
		m--;
	}
	if(m>=1){
		d+=30;
		m--;
	}
	if(m>=1){
		d+=31;
		m--;
	}
	if(m>=1){
		d+=31;
		m--;
	}
	if(m>=1){
		d+=30;
		m--;
	}
	if(m>=1){
		d+=31;
		m--;
	}
	if(m>=1){
		d+=30;
		m--;
	}
	if(m>=1){
		d+=31;
		m--;
	}
	int y1 = y;
	while(y>1970){
		if(y%4==0) d+=366;
		else d+=365;
		y--;
	}
	t+=s;
	t+=n*60;
	t+=h*3600;
	t+=d*86400;
	printf("UTC to Unix TIME:%d YEAR:%d MONTH:%d DAY:%d HOUR:%d MINUTE:%d SECOND:%d\n",t,y1,m1,d1,h,n,s);
	return 0;
}

int main(int argc, char *argv[]){
	if(argc<2) return 1;
	if(strncmp(argv[1],"unix",4)==0) return UnixtoUTC(atoi(argv[2]));
	if(strncmp(argv[1],"utc",3)==0 & argc>7) return UTCtoUnix(atoi(argv[2]),atoi(argv[3]),
												atoi(argv[4]),atoi(argv[5]),
												atoi(argv[6]),atoi(argv[7]));
	return 2;
}