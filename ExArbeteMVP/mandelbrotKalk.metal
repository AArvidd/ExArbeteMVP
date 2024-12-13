//
//  mandelbrotKalk.metal
//  ExArbeteMVP
//
//  Created by Arvid.Oscarsson on 2024-11-28.
//

#include <metal_stdlib>
using namespace metal;

kernel void calculate_madelbrot(
                                device int* iConst,
                                device float* fConst,
                                device int* out,
                                uint index [[thread_position_in_grid]])
{
    
    // iConst[0] == image width
    // iConst[1] == image height
    // fConst[0] == x position of the upper left pixle;
    // fConst[1] == y position of the upper left pixle;
    // fConst[2] == distens between two pixles in x and y direction
    
    
     
    
    uint px = index % iConst[0]; // x position of the pixle in image
    uint py = index / iConst[1]; // y position of the pixle in image
    
    float x = 0;
    float y = 0;
    float Cx = fConst[0] + (px * fConst[2]); // x position of the picle in mandelbrot set
    float Cy = fConst[1] - (py * fConst[2]); // y position of the pixle in mandelbrot set
    
    
    out[index] = 0xff000000;
    
    /*
    if(Cx == 0 && Cy == 0){
        out[index] = 0xff00ff00;
        return;
    }
    //*/
    
    //*
    
    for(int i = 0; i < 10000; i++){
        float xtemp = (x * x) - (y * y) + Cx;
        float ytemp = 2 * x * y + Cy;
        x = xtemp;
        y = ytemp;
        if((x * x) + (y * y) > 4){
            out[index] = 0xffffffff;
            return;
        }
    }
    //*/
    
    
}
