//an attempt to use a C library with GUI calls in a C program
#include "guilib.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#define BG 0b0000000000000000 //background color in 5:6:5 RGB
typedef struct {
	double x;	//upper left position
	double y;
	double vx;	//velocity
	double vy;
	double ax;	//acceleration
	double ay;
	double r;	//radius
	double m;
	int color;
} physobj;
screeninfo *screen; //screen resolution
double G = 6.673;//E-1; //this is usually E-11
double ds; //distance scale (real/sim)
double pds; //previous scale
int ox; //x offset
int pox; //previous
int oy; //y offset
int poy; //previous
char lines;
char plines;

void physdraw(physobj *p){
	int x = p->x/pds + pox;
	int y = p->y/pds + poy;
	//if(x==(int)((p->x + p->vx)/ds + ox) | y==(int)((p->y + p->vy)/ds + oy)){
	//	p->x = p->x + p->vx;
	//	p->y = p->y + p->vy;
	//}else{
		if((p->x + p->r)>=(screen->x - pox)*pds | (p->x - p->r)<=-pox*pds | (p->y + p->r)>=(screen->y - poy)*pds | (p->y - p->r)<=-poy*pds){
			if(x<=0) x=0;
			if(x>screen->x) x=screen->x - 1;
			if(y<=0) y=0;
			if(y>screen->y) y=screen->y - 1;
		}else{
			fillcircle(x,y,p->r/pds,BG);
		}
		if(plines){
			drawline(screen->x/2,screen->y/2,x,y,BG);
		}
		p->x = p->x + p->vx;
		p->y = p->y + p->vy;
		x = p->x/ds + ox;
		y = p->y/ds + oy;
		if((p->x + p->r)>=(screen->x - ox)*ds | (p->x - p->r)<=-ox*ds | (p->y + p->r)>=(screen->y - oy)*ds | (p->y - p->r)<=-oy*ds){
			if(x<=0) x=0;
			if(x>=screen->x) x=screen->x - 1;
			if(y<=0) y=0;
			if(y>screen->y) y=screen->y - 1;
		}else{
			fillcircle(x,y,p->r/ds,p->color);
		}
		if(lines){
			drawline(screen->x/2,screen->y/2,x,y,p->color);
		}
	//}
	p->vx = p->vx + p->ax;
	p->vy = p->vy + p->ay;
}

int R(int max){
	double r = rand();
	r = r/RAND_MAX;
	return (int)(r*max);
}

double sqroot(double m)
{
	double r;
	asm volatile("fsqrt"
		: "=t" (r)
		: "0" (m)
	);
	return r;
}

unsigned char inb(int port){
	unsigned char r;
	asm("xor %%eax, %%eax\n\t"
		"in %%dx, %%al"
		: "=a" (r)
		: "d" (port)
	);
	return r;
}

int main(int argc, char **argv){
	screen = getinfo();
	if(!screen->x | !screen->y){
		return 1;
	}
	struct timeval st, et;
	char keys[128] = { 0 };
	char running = 1;
	char help = 1;
while(running){
	gettimeofday(&st, NULL);
	srand((unsigned int)st.tv_usec);
	physobj obj[R(20) + 2];
	char len = sizeof(obj)/sizeof(physobj);
	char i;
	for(i=0;i<len;i++){
		obj[i].x=R(screen->x);
		obj[i].y=R(screen->y);
		obj[i].vx=0;
		obj[i].vy=0;
		obj[i].ax=0;
		obj[i].ay=0;
		obj[i].m=R(5)+1;
		obj[i].r=obj[i].m*10;
		obj[i].color=R(65535);
	}
	physobj ogobj[len];
	memcpy(ogobj,obj,sizeof(obj));
	char i2;
	char s[256] = { 0 };
	int frames = 0;
	int fr = 0;
	clear(BG);
	ox = screen->x*2/5;
	pox = ox;
	oy = screen->y*2/5;
	poy = oy;
	ds = 5;
	pds = ds;
	char ips=1;
	unsigned char key;
	char continued = 1;
	while(running & continued){
		for(i=0;i<len;i++){
			obj[i].ax = 0;
			obj[i].ay = 0;
			for(i2=0;i2<len;i2++){
				if(i2!=i){
					double dx = obj[i2].x - obj[i].x;
					double dy = obj[i2].y - obj[i].y;
					double d = sqroot(dx*dx + dy*dy);
					if(d <= obj[i].r + obj[i2].r){ //collision
						dx = dx*(obj[i].r + obj[i2].r)/d;
						dy = dy*(obj[i].r + obj[i2].r)/d;
						d = sqroot(dx*dx + dy*dy);
						double a = G*obj[i2].m/(dx*dx + dy*dy);
						obj[i].ax += a*dx/d;
						obj[i].ay += a*dy/d;
					}else{
						double a = G*obj[i2].m/(dx*dx + dy*dy);
						obj[i].ax += a*dx/d;
						obj[i].ay += a*dy/d;
					}
				}
			}
			physdraw(&obj[i]);
		}
		pox = ox;
		poy = oy;
		pds = ds;
		plines=lines;
		frames++;
		gettimeofday(&et, NULL);
		sprintf(s,"Gravity Test KEY:%02X OFF:(%+06d,%+06d) IPS:%02d DS:%02d #:%d",
				key,ox,oy,ips,(int)ds,len);
		if(et.tv_sec > st.tv_sec){
			st=et;
			sprintf(s,"%s FPS:%04d    ",s,frames);
			fr = frames;
			frames = 0;
		}else{
			sprintf(s,"%s FPS:%04d    ",s,fr);
		}
		drawtext(0,0,BG,~BG,s);
		if(help){
			drawtext(0,screen->y - 80,BG,~BG,
			"\nPress 'Q' or ESC to exit, '+' to zoom in, '-' to zoom out, '[' to decrease\n"
			"speed, ']' to increase speed, 'H' show help, 'L' to toggle lines, 'X' to reset\n"
			"zoom and offset, 'C' to remove artifacts, 'N' to generate a new system, and the\n"
			"arrow keys to change the offset.");
		}
		key = inb(0x60);
		if(key>=0x80) keys[key - 0x80] = 0;
		else if(keys[key]==0) keys[key] = 1;
		else if(keys[key]==1) keys[key] = 2;
		for(i=0;i<ips;i++){
			asm("hlt");
			key = inb(0x60);
			if(key>=0x80) keys[key - 0x80] = 0;
			else if(keys[key]==0) keys[key] = 1;
		}
		if(keys[1]	| keys[0x10]) running = 0; //ESC or Q
		if(keys[0xC]) ds += 0.01; //minus
		if(keys[0xD]>0 & ds > 1) ds -= 0.01; //plus
		if(keys[0x13]==1){ //R
			memcpy(obj,ogobj,sizeof(ogobj));
			clear(BG);
		}
		if(keys[0x1A]==1 & ips < 128) ips+=1; //left square bracket
		if(keys[0x1B]==1 & ips > 0) ips-=1; //rigt square bracket
		if(keys[0x23]==1){ //H
			if(help){
				help=0;
				clear(BG);
			}
			else help=1;
		}
		if(keys[0x26]==1){ //L
			if(lines) lines=0;
			else lines=1;
		}
		if(keys[0x2D]==1){ //X
			ox = screen->x*2/5;
			oy = screen->y*2/5;
			ds = 5;
		}
		if(keys[0x2E]==1) clear(BG); //C
		if(keys[0x31]==1) continued=0; //N
		if(keys[0x48]) oy += 2; //up
		if(keys[0x50]) oy -= 2; //down
		if(keys[0x4B]) ox += 2; //right
		if(keys[0x4D]) ox -= 2; //right
	}
}
	reset();
	return 0;
}