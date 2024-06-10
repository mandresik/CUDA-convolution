
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include "rgbConversion.h"
#include "Timer.h"
#include "Masks.h"

#define MASK_RADIUS 1
#define MASK_WIDTH 3 
#define MASK_SIZE 9
#define O_TILE_WIDTH 30
#define BLOCK_WIDTH O_TILE_WIDTH + MASK_WIDTH - 1

#define CUDA_CHECK( value ) {									\
	cudaError_t err = value;									\
	if( err != cudaSuccess ) {									\
		fprintf( stderr, "Error %s at line %d in file %s\n",	\
				cudaGetErrorString(err), __LINE__, __FILE__ );	\
		exit( 1 );												\
	} 															\
}


__global__ void convolution(const uchar* N, const float* __restrict__ M, uchar* P, int height, int width) {

	// shared memory 
	__shared__ uchar Ns[BLOCK_WIDTH][BLOCK_WIDTH];

	int tx = threadIdx.x;
	int ty = threadIdx.y;

	int row_o = blockIdx.y * O_TILE_WIDTH + ty;
	int col_o = blockIdx.x * O_TILE_WIDTH + tx;

	int row_i = row_o - MASK_RADIUS;
	int col_i = col_o - MASK_RADIUS;

	// copying data to shared memory
	if ((row_i >= 0) && (row_i < height) && (col_i >= 0) && (col_i < width)) {
		Ns[ty][tx] = N[row_i * width + col_i];
	}
	else {
		Ns[ty][tx] = 0.0f;
	}

	// wait until data are copied in all threads
	__syncthreads();

	// convolution calculation
	float result = 0.0f;

	if (ty < O_TILE_WIDTH && tx < O_TILE_WIDTH) {
		for (int i = 0; i < MASK_WIDTH; ++i) {
			for (int j = 0; j < MASK_WIDTH; ++j) {
				result += M[i * MASK_WIDTH + j] * Ns[i + ty][j + tx];
			}
		}

		if (row_o < height && col_o < width) {
			P[row_o * width + col_o] = static_cast<uchar>(result);
		}
	}

	__syncthreads();
}



int main()
{
	// input image
	png_img_t inputImage;
	std::string imageInputName = "images/6k_png_img.png";
	std::cout << "image: " << imageInputName << '\n';
	inputImage.read(imageInputName);
	int imageWidth = inputImage.get_width();
	int imageHeight = inputImage.get_height();
	int imageSize = imageWidth * imageHeight;

	// *******************************************************************
	//                    memory allocation on CPU
	// *******************************************************************
	uchar* host_input_red = (uchar*)malloc(sizeof(uchar) * imageSize);
	uchar* host_input_green = (uchar*)malloc(sizeof(uchar) * imageSize);
	uchar* host_input_blue = (uchar*)malloc(sizeof(uchar) * imageSize);
	uchar* host_output_red = (uchar*)malloc(sizeof(uchar) * imageSize);
	uchar* host_output_green = (uchar*)malloc(sizeof(uchar) * imageSize);
	uchar* host_output_blue = (uchar*)malloc(sizeof(uchar) * imageSize);

	// *******************************************************************
	//                    memory allocation on GPU
	// *******************************************************************
	uchar* device_input_red = NULL, * device_input_green = NULL, * device_input_blue = NULL;
	CUDA_CHECK(cudaMalloc((void**)&device_input_red, sizeof(uchar) * imageSize));
	CUDA_CHECK(cudaMalloc((void**)&device_input_green, sizeof(uchar) * imageSize));
	CUDA_CHECK(cudaMalloc((void**)&device_input_blue, sizeof(uchar) * imageSize));

	uchar* device_output_red = NULL, * device_output_green = NULL, * device_output_blue = NULL;
	CUDA_CHECK(cudaMalloc((void**)&device_output_red, sizeof(uchar) * imageSize));
	CUDA_CHECK(cudaMalloc((void**)&device_output_green, sizeof(uchar) * imageSize));
	CUDA_CHECK(cudaMalloc((void**)&device_output_blue, sizeof(uchar) * imageSize));

	// *******************************************************************
	//         get RGB input data and copy them from CPU to GPU
	// *******************************************************************
	pngToRgb(inputImage, host_input_red, host_input_green, host_input_blue);

	CUDA_CHECK(cudaMemcpy(device_input_red, host_input_red, sizeof(uchar) * imageSize, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(device_input_green, host_input_green, sizeof(uchar) * imageSize, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(device_input_blue, host_input_blue, sizeof(uchar) * imageSize, cudaMemcpyHostToDevice));

	// *******************************************************************
	//   memory allocation of mask on CPU, pick data and copy to GPU
	// *******************************************************************
	float* host_mask = (float*)malloc(sizeof(float) * MASK_SIZE);
	Masks maskMatrices;
	std::string strOutputName = "boxBlur";
	std::cout << "convolution matrix effect: " << strOutputName << '\n';
	for (int i = 0; i < MASK_SIZE; ++i) {
		host_mask[i] = maskMatrices.boxBlur[i];
	}

	float* device_mask = NULL;
	CUDA_CHECK(cudaMalloc((void**)&device_mask, sizeof(float) * MASK_SIZE));
	CUDA_CHECK(cudaMemcpy(device_mask, host_mask, sizeof(float) * MASK_SIZE, cudaMemcpyHostToDevice));

	// *******************************************************************
	//                          calculation
	// *******************************************************************
	// number of threads and block size
	dim3 dimBlock(BLOCK_WIDTH, BLOCK_WIDTH);
	dim3 dimGrid((imageWidth + O_TILE_WIDTH - 1) / O_TILE_WIDTH, (imageHeight + O_TILE_WIDTH - 1) / O_TILE_WIDTH);

	Timer timer;
	timer.start();

	convolution <<<dimGrid, dimBlock>>> (device_input_red, device_mask, device_output_red, imageHeight, imageWidth);
	convolution <<<dimGrid, dimBlock>>> (device_input_green, device_mask, device_output_green, imageHeight, imageWidth);
	convolution <<<dimGrid, dimBlock>>> (device_input_blue, device_mask, device_output_blue, imageHeight, imageWidth);

	timer.stop("time of all rgb data calculation");

	CUDA_CHECK(cudaDeviceSynchronize());
	CUDA_CHECK(cudaGetLastError());

	// *******************************************************************
	//        copy calculated values from GPU to CPU and save them
	// *******************************************************************
	CUDA_CHECK(cudaMemcpy(host_output_red, device_output_red, sizeof(uchar) * imageSize, cudaMemcpyDeviceToHost));
	CUDA_CHECK(cudaMemcpy(host_output_green, device_output_green, sizeof(uchar) * imageSize, cudaMemcpyDeviceToHost));
	CUDA_CHECK(cudaMemcpy(host_output_blue, device_output_blue, sizeof(uchar) * imageSize, cudaMemcpyDeviceToHost));

	png_img_t outputImage(imageWidth, imageHeight);
	rgbToPng(host_output_red, host_output_green, host_output_blue, outputImage);
	std::string outputPath = "images/output_6k_";
	outputPath.append(strOutputName);
	outputPath.append(".png");
	outputImage.write(outputPath);

	// *******************************************************************
	//            free all allocated GPU and CPU memory
	// *******************************************************************

	CUDA_CHECK(cudaFree((void*)device_input_red));
	CUDA_CHECK(cudaFree((void*)device_input_green));
	CUDA_CHECK(cudaFree((void*)device_input_blue));
	CUDA_CHECK(cudaFree((void*)device_output_red));
	CUDA_CHECK(cudaFree((void*)device_output_green));
	CUDA_CHECK(cudaFree((void*)device_output_blue));

	free(host_input_red);
	free(host_input_green);
	free(host_input_blue);
	free(host_output_red);
	free(host_output_green);
	free(host_output_blue);

	CUDA_CHECK(cudaDeviceReset());

    return 0;
}


