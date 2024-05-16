#pragma once

#include "png++-0.2.9/png.hpp"

typedef unsigned char uchar;
typedef png::image<png::rgb_pixel> png_img_t;

void pngToRgb(png_img_t& img, uchar* r, uchar* g, uchar* b);

void rgbToPng(uchar* r, uchar* g, uchar* b, png_img_t& img);