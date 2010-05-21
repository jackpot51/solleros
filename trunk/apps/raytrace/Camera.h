typedef struct{
	Vector from;
	Vector to;
	int resX;
	int resY;
} Camera;

void CameraStart(Camera *cam){
	cam->from.x = -1;
	cam->from.y = -1;
}

void CameraNext(Camera *cam){
	cam->from.x += 2.0/cam->resX;
	if(cam->from.x >= 1.0)
	{
		cam->from.x = -1.0;
		cam->from.y += 2.0/cam->resY;
	}
}