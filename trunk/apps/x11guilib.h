#include <string.h>
#include <sys/time.h>
#include <X11/Xlib.h> // Every Xlib program must include this

typedef struct {
	int x;
	int y;
	int color;
} screeninfo;

char _set = 0;
char _timeset = 0;
Display *_dpy;
Window _win;
int _blackColor;
int _whiteColor;
GC _gc;
struct timeval _timeoday;

void _setup(){
	// Open the display
	_dpy = XOpenDisplay((0));

	_blackColor = BlackPixel(_dpy, DefaultScreen(_dpy));
	_whiteColor = WhitePixel(_dpy, DefaultScreen(_dpy));

	_win = XCreateSimpleWindow(_dpy, DefaultRootWindow(_dpy), 0, 0, 
		 	1024, 768, 0, _blackColor, _blackColor);

	// We want to get MapNotify events
	XSelectInput(_dpy, _win, StructureNotifyMask);

	// "Map" the _window (that is, make it appear on the screen)
	XMapWindow(_dpy, _win);

	// Create a "Graphics Context"
	_gc = XCreateGC(_dpy, _win, 0, (0));

	// Tell the GC we draw using the white color
	XSetForeground(_dpy, _gc, _whiteColor);

	// Wait for the MapNotify event
	for(;;) {
		XEvent e;
		XNextEvent(_dpy, &e);
		if(e.type == MapNotify)
			break;
	}
	XGrabKeyboard(_dpy, _win, 1, GrabModeAsync, GrabModeAsync, CurrentTime);
	_set = 1;
}

void hlt(){
	if(!_timeset){
		usleep(2250);
		gettimeofday(&_timeoday,NULL);
		_timeset = 1;
	}else{
		long next = _timeoday.tv_sec*1000000 + _timeoday.tv_usec;
		gettimeofday(&_timeoday,NULL);
		long cur = _timeoday.tv_sec*1000000 + _timeoday.tv_usec;
		while(next<cur)
			next += 2150;
		int mt = (int)(next - cur);
		usleep(mt);
		gettimeofday(&_timeoday,NULL);
	}
}

unsigned char inb(int port){
//	if(port==0x60){
//		XKeyEvent ke;
//		XNextEvent(_dpy, (XEvent *)&ke);
//		if(ke.type == KeyPress) return ke.keycode;
//		if(ke.type == KeyRelease) return ke.keycode;
//	}
//	else
	return 0;
}

int Convert(int color){
	int c = (color&0xF800)<<8;
	c += (color&0x7E0)<<5;
	c += (color&0x1F)<<3;
	return c;
}

void clear(int color){
	if(!_set) _setup();
	XSetWindowBackground(_dpy, _win, Convert(color));
	XClearWindow(_dpy, _win);
    XFlush(_dpy);
}

void putpixel(int x, int y, int color){
	if(!_set) _setup();
	XSetForeground(_dpy, _gc, Convert(color));
	XDrawPoint(_dpy, _win, _gc, x, y);
	XFlush(_dpy);
}

void drawtext(int x, int y, int back, int fore, char *text){
	if(!_set) _setup();
	XSetBackground(_dpy, _gc, Convert(back));
	XSetForeground(_dpy, _gc, Convert(fore));
	XDrawImageString(_dpy, _win, _gc, x, y + 10, text, strlen(text));
	XFlush(_dpy);
}

void drawline(int x, int y, int x2, int y2, int color){
	if(!_set) _setup();
   	XSetForeground(_dpy, _gc, Convert(color));
    XDrawLine(_dpy, _win, _gc, x, y, x2, y2);
    XFlush(_dpy);
}

void drawcircle(int x, int y, int radius, int color){
	if(!_set) _setup();
	XSetForeground(_dpy, _gc, Convert(color));
	x-=radius;
	y-=radius;
	radius+=radius;
	XDrawArc(_dpy, _win, _gc, x, y, radius, radius, 0, 360*65);
    XFlush(_dpy);
}

void fillcircle(int x, int y, int radius, int color){
	if(!_set) _setup();
	XSetForeground(_dpy, _gc, Convert(color));
	x-=radius;
	y-=radius;
	radius+=radius;
	XFillArc(_dpy, _win, _gc, x, y, radius, radius, 0, 360*65);
    XFlush(_dpy);
}

void drawrect(int x, int y, int x2, int y2, int color){
	if(!_set) _setup();
	XSetForeground(_dpy, _gc, Convert(color));
	int w;
	if(x>x2){
		w=x-x2;
		x=x2;
	}
	else w=x2-x;
	int h;
	if(y>y2){
		h=y-y2;
		y=y2;
	}
	else h=y2-y;
	XDrawRectangle(_dpy, _win, _gc, x, y, w, h);
	XFlush(_dpy);
}

void fillrect(int x, int y, int x2, int y2, int color){
	if(!_set) _setup();
	XSetForeground(_dpy, _gc, Convert(color));
	int w;
	if(x>x2){
		w=x-x2;
		x=x2;
	}
	else w=x2-x;
	int h;
	if(y>y2){
		h=y-y2;
		y=y2;
	}
	else h=y2-y;
	XFillRectangle(_dpy, _win, _gc, x, y, w, h);
	XFlush(_dpy);
}

void getinfo(screeninfo * sc){
	if(!_set) _setup();
	sc->x=1024;
	sc->y=768;
	sc->color=_blackColor;
}

void reset(){
	if(!_set) _setup();
	XSetForeground(_dpy, _gc, _whiteColor);
	XSetBackground(_dpy, _gc, _blackColor);
	clear(0);
}
