//
//  MetalSetupp.h
//  ExArbeteMVP
//
//  Created by Arvid.Oscarsson on 2024-11-28.
//

#import <Foundation/Foundation.h>
#import "Metal/Metal.h"


NS_ASSUME_NONNULL_BEGIN

@interface MetalSetupp : NSObject
- (instancetype) initWithDevice: (id<MTLDevice>) device;
- (void) prepareData;
- (void) SendComputeCommand;
@end

NS_ASSUME_NONNULL_END
