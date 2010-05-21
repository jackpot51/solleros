#include "guilib.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>
double sqroot(double m)
{
	double r;
	asm volatile("fsqrt"
		: "=t" (r)
		: "0" (m)
	);
	return r;
}
screeninfo *screen;
#include "raytrace/Vector.h"
#include "raytrace/Camera.h"
#include "raytrace/Color.h"
#include "raytrace/Sphere.h"
#include "raytrace/Light.h"
#include "raytrace/LightIntensity.h"
#include "raytrace/View2D.h"

double R(double max){
	double r = rand();
	r = r/RAND_MAX;
	return r*max;
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

void nextFrame(View2D TheImage, Camera TheCamera, Sphere s, Color bcol, LightIntensity LIntensity){
	for(CameraStart(&TheCamera);TheCamera.from.y<1;CameraNext(&TheCamera)){
		Vector v = {0,0,0};
		Color col = {0,0,0};
		if(SphereDoesRayIntersect(s,TheCamera.from,TheCamera.to,&v)==1){
			LightIntensityDetermineIntensity(LIntensity,v,s.c,&col);
			View2DDrawPixel(TheImage,col,v);
		}else{
			View2DDrawPixel(TheImage,bcol,v);
		}
	}
}

int main(int argc, char *argv[]){
	getinfo(screen);
	if(!screen->x | !screen->y){
		_exit(1);
	}
	clear(0);
	
	struct timeval st;
	gettimeofday(&st, NULL);
	srand((unsigned int)st.tv_usec);
	
	Vector p = {0,0,0};
	Color c = {R(1),R(1),R(1)};
	Sphere s = {0.5,p,c};
	
	LightIntensity LIntensity = {newLight(R(2) - 1,R(2) - 1,-1),0.3};
	
	Vector from = {0,0,3};
	Vector to = {0,0,-1};
	Camera TheCamera = {from,to,screen->y,screen->y};

	View2D TheImage = {TheCamera.resX, TheCamera.resY};
	Color bcol = {0.5,0.5,0.5};
	
	nextFrame(TheImage,TheCamera,s,bcol,LIntensity);

	drawtext(0,0,0,0xFFFF,"Press q to exit.");	
	unsigned char key = 0;
	while(key!=0x10){
			key = inb(0x60);
			asm("hlt");
			if(key==0x48 & LIntensity.light.y<1){ //up
					LIntensity.light.y-=0.4;
					nextFrame(TheImage,TheCamera,s,bcol,LIntensity);
			}
			if(key==0x50 & LIntensity.light.y>-1){ //down
					LIntensity.light.y+=0.4;
					nextFrame(TheImage,TheCamera,s,bcol,LIntensity);
			}
			if(key==0x4B & LIntensity.light.x>-1){ //left
					LIntensity.light.x-=0.4;
					nextFrame(TheImage,TheCamera,s,bcol,LIntensity);
			}
			if(key==0x4D & LIntensity.light.x<1){ //right
					LIntensity.light.x+=0.4;
					nextFrame(TheImage,TheCamera,s,bcol,LIntensity);
			}
	}
	reset();
	_exit(0);
}