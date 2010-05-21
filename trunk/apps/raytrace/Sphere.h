typedef struct{
	double r;
	Vector p;
	Color c;
} Sphere;

char SphereDoesRayIntersect(Sphere s,Vector from,Vector to,Vector *v){
	Vector vec = VectorSub(from,s.p);
	double b = VectorDot(to,vec);
	double c = VectorDot(vec,vec) - s.r*s.r;
	double d = b*b-c;
	if(d<0) return 0;
	double det = sqroot(d);
	double t = det - b;
	if(t<0) return 0;
	Vector v1 = VectorAdd(VectorMul(to,t),from);
	v1 = VectorSub(v1,s.p);
	VectorNormalize(&v1);
	v->x = v1.x;
	v->y = v1.y;
	v->z = v1.z;
	return 1;
}