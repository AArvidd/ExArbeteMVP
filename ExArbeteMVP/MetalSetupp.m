//
//  MetalAdder.m
//  metalTest2
//
//  Created by Arvid.Oscarsson on 2024-11-22.
//

#import "MetalSetupp.h"

#define PRECISION_TYPE float

float X = -0.7498;
float Y = 0.02;

float width = 0.0001;

const unsigned int pWidth = 10000;
const unsigned int pHeight = 10000;

const unsigned long arrayLength = pWidth * pHeight;
const unsigned long bufferSize = arrayLength * sizeof(int);

@implementation MetalSetupp{
    id<MTLDevice> _mDevice;
    
    id<MTLComputePipelineState> _mAddFunctionPSO;
    
    id<MTLCommandQueue> _mCommandQueue;
    
    id<MTLBuffer> _mBufferConstI;
    id<MTLBuffer> _mBufferConstF;
    
    id<MTLBuffer> _mBufferOut;
    
}

- (instancetype _Nonnull ) initWithDevice: (id<MTLDevice>_Nonnull)device {
    self = [super init];
    if(self){
        _mDevice = device;
        
        NSError* error = nil;
        
        id<MTLLibrary> deafultLibrary = [_mDevice newDefaultLibrary];
        if(deafultLibrary == nil){
            NSLog(@"Faild to find the default library");
            return nil;
        }
        
        id<MTLFunction> addFunction = [deafultLibrary newFunctionWithName:@"calculate_madelbrot"];
        if(addFunction == nil){
            NSLog(@"Faild to find the adder function");
            return nil;
        }
        
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction:addFunction error:&error];
        if(_mAddFunctionPSO == nil){
            NSLog(@"Faild to create pipeline state object, error %@", error);
            return nil;
        }
        
        _mCommandQueue = [_mDevice newCommandQueue];
        if(_mCommandQueue == nil){
            NSLog(@"Faild to find comand queue");
            return nil;
        }
    }
    return self;
}

- (void) prepareData{
    
    PRECISION_TYPE deltaPixle = width / pWidth;
    
    PRECISION_TYPE upperLeftX = X - (pWidth / 2) * deltaPixle;
    PRECISION_TYPE upperLEftY = Y + (pHeight / 2) * deltaPixle;
    
    _mBufferConstI = [_mDevice newBufferWithLength:2 * sizeof(int) options:MTLResourceStorageModeShared];
    _mBufferConstF = [_mDevice newBufferWithLength:3 * sizeof(PRECISION_TYPE) options:MTLResourceStorageModeShared];
    _mBufferOut = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    
    
    int* constIP = _mBufferConstI.contents;
    PRECISION_TYPE* constFP = _mBufferConstF.contents;
    constIP[0] = pWidth;
    constIP[1] = pHeight;
    
    constFP[0] = upperLeftX;
    constFP[1] = upperLEftY;
    constFP[2] = deltaPixle;
    
}

- (void) SendComputeCommand {
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    assert(commandBuffer != nil);
    
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);
    
    [self encodeAddCommand:computeEncoder];
    
    [computeEncoder endEncoding];
    
    [commandBuffer commit];
    
    [commandBuffer waitUntilCompleted];
    
    //[self verifyResults];
    
    /*
    
    int* a = _mBufferOut.contents;
    
    for(int i = 0; i < arrayLength; i++){
        printf("%d: %d\n", i, a[i]);
    }
     
    */
    
    [self saveImage];
}

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>_Nonnull)computeEncoder {
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:_mBufferConstI offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferConstF offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferOut offset:0 atIndex:2];
    
    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
    
    NSUInteger thredGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if(thredGroupSize > arrayLength){
        thredGroupSize = arrayLength;
    }
    MTLSize thredgroupSize = MTLSizeMake(thredGroupSize, 1, 1);
    
    [computeEncoder dispatchThreads:gridSize threadsPerThreadgroup:thredgroupSize];
}

- (void) saveImage{
    
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [[path objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
    
    int* data = _mBufferOut.contents;
    
    if(!data){
        NSLog(@"faild to allocate memory");
        return;
    }
    
    //data[0] = 0xffffffff;
    //data[1] = 0xff00ff00;
    //data[2] = 0xffff0000;
    
    //data[arrayLength - 1] = 0xffff0000;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(data, pWidth, pHeight, 8, pWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    
    if(!context){
        NSLog(@"faild context");
        free(data);
        return;
    }
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    if(!cgImage){
        NSLog(@"faild cgImage");
        return;
    }
    
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    
    CGImageDestinationAddImage(destination, cgImage, nil);
    CGImageDestinationFinalize(destination);
    
    CFRelease(destination);
    printf("done\n");
}

- (void) verifyResults{
    short* a = _mBufferOut.contents;
    
    for(int i = 0; i < arrayLength; i++){
        NSLog(@"%d: %d", i, a[i]);
        
    }
    //printf("Compute resulte as expected\n");
}

@end
