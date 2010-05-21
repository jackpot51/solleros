typedef struct{
	double x;
	double y;
	double z;
} Vector;

void VectorNormalize(Vector *v){
		double d = sqroot(v->x*v->x+v->y*v->y+v->z*v->z);
		v->x = v->x/d;
		v->y = v->y/d;
		v->z = v->z/d;
}

Vector VectorAdd(Vector v1, Vector v2){
	Vector vr = {v1.x + v2.x, v1.y + v2.y, v1.z + v2.z};
	return vr;
}

Vector VectorSub(Vector v1, Vector v2){
	Vector vr = {v1.x - v2.x, v1.y - v2.y, v1.z - v2.z};
	return vr;
}

Vector VectorMul(Vector v1, double d){
	Vector vr = {v1.x*d, v1.y*d, v1.z*d};
	return vr;
}

double VectorDot(Vector v1, Vector v2){
	return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}