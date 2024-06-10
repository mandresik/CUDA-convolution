# Convolution with CUDA (in progress)
In this project, convolution of image is calculated parallely on Nvidia gpu. For png, png++ (included in project) and libpng (installed via vcpkg) are used.
* Folder for images is called images in the project and contains some input and output images,
* convolution and main are in kernel.cu,
* Timer class purpose is to measure time in any block of code,
* rgbConversion purpose is to convert png to rgb and vica versa,
* Masks class contains masks (kernel matrices) for convolution.

Everything is setup in main function. We choose what image we want to work with, this image is read. Then, memory for this image data (RGB) is allocated both on cpu and gpu. After that, png data are converted to the rgb data on cpu, cpu data are copied to gpu. We choose what mask we want to use from Masks, this data are also copied to the gpu. After that, the convolution is calculated (and of course the time of calculation is measured). After that, calculated results are copied back from gpu to cpu, then rgb data are converted to png and this png result is saved in specified images folder. Lastly, all the allocated memory is free.

## Example
Below, we can see an input and output example of an edge detection. 

![time]

### Input
![in]

### Output
![out]


[x]: https://github.com/mandresik/CUDA-convolution/blob/main/cuda_convolution/images/console_screen.png?raw=true
[time]: https://live.staticflickr.com/65535/53781702422_5765a1648b_w.jpg
[in]: https://github.com/mandresik/CUDA-convolution/blob/main/cuda_convolution/images/6k_png_img.png?raw=true
[out]: https://github.com/mandresik/CUDA-convolution/blob/main/cuda_convolution/images/output_6k_edges1.png?raw=true
