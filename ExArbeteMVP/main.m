//
//  main.m
//  ExArbeteMVP
//
//  Created by Arvid.Oscarsson on 2024-11-28.
//

#import <Foundation/Foundation.h>
#import "Metal/Metal.h"
#import "MetalSetupp.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        
        MetalSetupp* adder = [[MetalSetupp alloc] initWithDevice:device];
        
        [adder prepareData];
        
        [adder SendComputeCommand];
        
    }
    return 0;
}
