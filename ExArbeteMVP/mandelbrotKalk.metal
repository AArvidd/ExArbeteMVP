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
                                texture2d<half, access::write> out,
                                uint index [[thread_position_in_grid]])
{
    
    // iConst[0] == image width
    // iConst[1] == image height
    // fConst[0] == x position of the upper left pixle;
    // fConst[1] == y position of the upper lif tpixle;
    // fConst[2] == distens between two pixles in x and y direction
    
    uint px = index % iConst[0]; // x position of the pixle in image
    uint py = index / iConst[1]; // y position of the pixle in image
    
    float x = 0;
    float y = 0;
    float Cx = fConst[0] - (px * fConst[2]); // x position of the picle in mandelbrot set
    float Cy = fConst[1] - (py * fConst[2]); // y position of the pixle in mandelbrot set
    
    uint2 grid = uint2(px, py);
    
    out.write(1, grid);
    
    for(int i = 0; i < 1000; i++){
        float xtemp = (x * x) - (y * y) + Cx;
        float ytemp = 2 * x * y + Cy;
        x = xtemp;
        y = ytemp;
        if((x * x) + (y * y) > 4){
            out.write(0, grid);
            return;
        }
    }
}
