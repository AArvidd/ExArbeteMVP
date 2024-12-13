//
//  MetalSetupp.h
//  ExArbeteMVP
//
//  Created by Arvid.Oscarsson on 2024-11-28.
//

#import <Foundation/Foundation.h>
#import "Metal/Metal.h"
#import "CoreGraphics/CoreGraphics.h"
#import "CoreServices/CoreServices.h"
#import "ImageIO/ImageIO.h"
//#import "UniformTypeIdentifiers/UniformTypeIdentifiers.h"



NS_ASSUME_NONNULL_BEGIN

@interface MetalSetupp : NSObject
- (instancetype) initWithDevice: (id<MTLDevice>) device;
- (void) prepareData;
- (void) SendComputeCommand;
@end

NS_ASSUME_NONNULL_END
