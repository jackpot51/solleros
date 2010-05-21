typedef struct{
	Vector light;
	double ambient;
} LightIntensity;

void LightIntensityDetermineIntensity(LightIntensity l, Vector v, Color b, Color *c){
	c->r = b.r*(VectorDot(l.light,v) + l.ambient);
	c->g = b.g*(VectorDot(l.light,v) + l.ambient);
	c->b = b.b*(VectorDot(l.light,v) + l.ambient);
	if(c->r<0) c->r = -c->r;
	if(c->g<0) c->g = -c->g;
	if(c->b<0) c->b = -c->b;
}