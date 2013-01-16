//
//  DrawRecoveryService.m
//  Draw
//
//  Created by qqn_pipi on 13-1-16.
//
//

#import "DrawRecoveryService.h"
#import "SynthesizeSingleton.h"



@implementation DrawRecoveryService

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawRecoveryService)

- (void)test
{
    [DrawRecoveryService defaultService];
}



@end
