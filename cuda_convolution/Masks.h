#pragma once

#define MASK_WIDTH 3 
#define MASK_SIZE 9

class Masks
{
public:
	float boxBlur[MASK_SIZE] = {
		0.11f, 0.11f, 0.11f, 
		0.11f, 0.11f, 0.11f, 
		0.11f, 0.11f, 0.11f
	};
	float gaussianBlur[MASK_SIZE] = {
		0.0625f, 0.125f, 0.625f,
		0.125f, 0.25f, 0.125f, 
		0.0625f, 0.125f, 0.625f
	};
	float edgeDetection1[MASK_SIZE] = {
		-1.0f, -2.0f, -1.0f, 
		0.0f, 0.0f, 0.0f, 
		1.0f, 2.0f, 1.0f
	};
	float edgeDetection2[MASK_SIZE] = {
		0.0f, -1.0f, 0.0f, 
		-1.0f, 4.0f, -1.0f, 
		0.0f, -1.0f, 0.0f
	};
	float sharpen[MASK_SIZE] = {
		0.0f, -1.0f, 0.0f, 
		-1.0f, 5.0f, -1.0f, 
		0.0f, -1.0f, 0.0f
	};
	float effect3d[MASK_SIZE] = {
		-2.0f, -1.0f, 0.0f, 
		-1.0f, 1.0f, 1.0f, 
		0.0f, 1.0f, 2.0f
	};
};

