typedef struct{
	int resX;
	int resY;
} View2D;

void View2DDrawPixel(View2D v2d, Color col, Vector pos){
	int x = (int)((pos.x+1)*(v2d.resX/4)) + screen->x/16;
	int y = (int)((pos.y+1)*(v2d.resY/4)) + screen->y/16;
	if(x<screen->x & y<screen->y & x>0 & y>0)
		drawline(x,y,x+1,y,ColorTo16(col));
}