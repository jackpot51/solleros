typedef struct {
	int x;
	int y;
	int color;
} screeninfo;

void clear(int color){
	asm volatile("movb $17, %%ah\n\t"
		"xorb %%al, %%al\n\t"
		"int $0x30"
	:
	: "b" (color)
	: "%eax", "%ecx", "%edx", "%edi", "%esi"
	);
}

void putpixel(int x, int y, int color){
	asm volatile("movb $17, %%ah\n\t"
		"movb $1, %%al\n\t"
		"int $0x30"
	:
	: "d" (x), "c" (y), "b" (color)
	: "%eax", "%edi", "%esi"
	);
}

void drawtext(int x, int y, int back, int fore, char *text){
	asm volatile("movb $17, %%ah\n\t"
		"movb $2, %%al\n\t"
		"int $0x30"
	:
	: "d" (x), "c" (y), "D" (back), "b" (fore), "S" (text)
	: "%eax"
	);
}

void drawline(int x, int y, int x2, int y2, int color){
	asm volatile("movb $17, %%ah\n\t"
		"movb $3, %%al\n\t"
		"int $0x30"
	:
	: "d" (x), "c" (y), "D" (x2), "S" (y2), "b" (color)
	: "%eax"
	);
}

void drawcircle(int x, int y, int radius, int color){
	asm volatile("movb $17, %%ah\n\t"
		"movb $4, %%al\n\t"
		"int $0x30"
	:
	: "d" (x), "c" (y), "S" (radius), "b" (color)
	: "%eax", "%edi"
	);
}

void fillcircle(int x, int y, int radius, int color){
	asm volatile("movb $17, %%ah\n\t"
		"movb $5, %%al\n\t"
		"int $0x30"
	:
	: "d" (x), "c" (y), "S" (radius), "b" (color)
	: "%eax", "%edi"
	);
}

void drawsquare(int x, int y, int x2, int y2, int color){
	asm volatile("movb $17, %%ah\n\t"
		"movb $6, %%al\n\t"
		"int $0x30"
	:
	: "d" (x), "c" (y), "D" (x2), "S" (y2), "b" (color)
	: "%eax"
	);
}

void fillsquare(int x, int y, int x2, int y2, int color){
	asm volatile("movb $17, %%ah\n\t"
		"movb $7, %%al\n\t"
		"int $0x30"
	:
	: "d" (x), "c" (y), "D" (x2), "S" (y2), "b" (color)
	: "%eax"
	);
}

screeninfo *getinfo(){
	screeninfo *sc;
	asm volatile("movb $17, %%ah\n\t"
		"movb $253, %%al\n\t"
		"int $0x30"
	: "=d" (sc->x), "=c" (sc->y), "=b" (sc->color)
	:
	);
	return sc;
}

void reset(){
	asm volatile("movb $17, %%ah\n\t"
		"movb $255, %%al\n\t"
		"int $0x30"
	:
	:
	: "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi"
	);
}