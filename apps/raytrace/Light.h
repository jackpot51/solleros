Vector newLight(double x, double y, double z){
	Vector lr = {x,y,z};
	VectorNormalize(&lr);
	return lr;
}