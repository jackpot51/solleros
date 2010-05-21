typedef struct{
	double r;
	double g;
	double b;
} Color;

int ColorIntR(Color c){
	int ir = (int)(255*c.r);
	ir = ir > 255 ? 255 : ir;
	return ir < 0 ? 0 : ir;
}

int ColorIntG(Color c){
	int ir = (int)(255*c.g);
	ir = ir > 255 ? 255 : ir;
	return ir < 0 ? 0 : ir;
}

int ColorIntB(Color c){
	int ir = (int)(255*c.b);
	ir = ir > 255 ? 255 : ir;
	return ir < 0 ? 0 : ir;
}

int ColorTo16(Color c){
	int cr = ColorIntB(c)>>3;
	cr += ColorIntG(c)>>2<<5;
	cr += ColorIntR(c)>>3<<11;
	return cr;
}