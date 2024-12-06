//
//  MetalAdder.m
//  metalTest2
//
//  Created by Arvid.Oscarsson on 2024-11-22.
//

#import "MetalSetupp.h"

#define PRECISION_TYPE float
#define X_UPPER_LEFT 0.5f
#define Y_UPPER_LEFT 0.5f
#define DELTA_PIXEL 0.001f

const unsigned int width = 10;
const unsigned int height = 10;

const unsigned int arrayLength = width * height;
const unsigned int bufferSize = arrayLength * sizeof(int);

@implementation MetalSetupp{
    id<MTLDevice> _mDevice;
    
    id<MTLComputePipelineState> _mAddFunctionPSO;
    
    id<MTLCommandQueue> _mCommandQueue;
    
    id<MTLBuffer> _mBufferConstI;
    id<MTLBuffer> _mBufferConstF;
    id<MTLBuffer> _mBufferA;
    
    id<MTLBuffer> _mBufferOut;
    id<MTLTexture> _mTextureOut;
    
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
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    
    _mBufferConstI = [_mDevice newBufferWithLength:2 * sizeof(int) options:MTLResourceStorageModeShared];
    _mBufferConstF = [_mDevice newBufferWithLength:3 * sizeof(PRECISION_TYPE) options:MTLResourceStorageModeShared];
    _mBufferOut = [_mDevice newBufferWithLength:4 * width * height options:MTLResourceStorageModeShared];
    
    MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Uint width:width height:height mipmapped:false];
    
    _mTextureOut = [_mDevice newTextureWithDescriptor:descriptor];
    
    
    
    int* constIP = _mBufferConstI.contents;
    PRECISION_TYPE* constFP = _mBufferConstF.contents;
    constIP[0] = width;
    constIP[1] = height;
    
    constFP[0] = X_UPPER_LEFT;
    constFP[1] = Y_UPPER_LEFT;
    constFP[2] = DELTA_PIXEL;
    
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
    
    [self verifyResults];
}

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>_Nonnull)computeEncoder {
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:_mBufferConstI offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferConstF offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:2];
    
    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
    
    NSUInteger thredGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if(thredGroupSize > arrayLength){
        thredGroupSize = arrayLength;
    }
    MTLSize thredgroupSize = MTLSizeMake(thredGroupSize, 1, 1);
    
    [computeEncoder dispatchThreads:gridSize threadsPerThreadgroup:thredgroupSize];
}

- (void) generateRandomFloatData: (id<MTLBuffer>_Nonnull) buffer {
    float* dataPtr = buffer.contents;
    
    for(unsigned long i = 0; i < arrayLength; i++){
        dataPtr[i] = (float)rand()/(float)(RAND_MAX);
    }
}

- (void) saveImage: (id<MTLTexture>) texture {
    unsigned long width = texture.width;
    unsigned long height = texture.height;
    int pixlesByteCount = 4 * 32;
    unsigned long imageBytePerRow = width * pixlesByteCount;
    unsigned long imageByteCount = imageBytePerRow * height;
    int* imageBytes = malloc(imageByteCount);
    
    [texture getBytes:imageBytes bytesPerRow:imageBytePerRow fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
    
    
    
    free(imageBytes);
    
}

- (void) verifyResults{
    float* a = _mBufferA.contents;
    
    for(unsigned long i = 0; i < arrayLength; i++){
        printf("i = %lu: thred = %f\n", i, a[i]);
    }
    printf("Compute resulte as expected\n");
}

@end
