#pragma once



class Masks
{
public:
	float boxBlur[9] = {
		0.11f, 0.11f, 0.11f, 
		0.11f, 0.11f, 0.11f, 
		0.11f, 0.11f, 0.11f
	};
	float gaussianBlur[9] = {
		0.0625f, 0.125f, 0.625f,
		0.125f, 0.25f, 0.125f, 
		0.0625f, 0.125f, 0.625f
	};
	float edgeDetection1[9] = {
		-1.0f, -2.0f, -1.0f, 
		0.0f, 0.0f, 0.0f, 
		1.0f, 2.0f, 1.0f
	};
	float edgeDetection2[9] = {
		0.0f, -1.0f, 0.0f, 
		-1.0f, 4.0f, -1.0f, 
		0.0f, -1.0f, 0.0f
	};
	float sharpen[9] = {
		0.0f, -1.0f, 0.0f, 
		-1.0f, 5.0f, -1.0f, 
		0.0f, -1.0f, 0.0f
	};
	float effect3d[9] = {
		-2.0f, -1.0f, 0.0f, 
		-1.0f, 1.0f, 1.0f, 
		0.0f, 1.0f, 2.0f
	};
};

