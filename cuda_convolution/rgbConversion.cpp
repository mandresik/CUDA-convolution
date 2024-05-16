#include "rgbConversion.h"


void pngToRgb(png_img_t& img, uchar* r, uchar* g, uchar* b) {
    for (size_t y = 0; y < img.get_height(); ++y) {
        for (size_t x = 0; x < img.get_width(); ++x) {
            png::rgb_pixel px = img.get_pixel(x, y);
            *r++ = px.red;
            *g++ = px.green;
            *b++ = px.blue;
        }
    }
}

void rgbToPng(uchar* r, uchar* g, uchar* b, png_img_t& img) {
    for (size_t y = 0; y < img.get_height(); ++y) {
        for (size_t x = 0; x < img.get_width(); ++x) {
            img.set_pixel(x, y, png::rgb_pixel(*r++, *g++, *b++));
        }
    }
}