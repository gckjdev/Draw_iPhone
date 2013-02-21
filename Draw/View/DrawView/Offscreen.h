//
//  Offscreen.h
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import <Foundation/Foundation.h>


@interface Offscreen : NSObject

@property(nonatomic, assign, readonly)NSUInteger actionCount;
@property(nonatomic, assign, readonly)NSUInteger capacity;


+ (id)offscreenWithCapacity:(NSUInteger)capacity;
+ (id)unlimitOffscreen;

- (id)initWithCapacity:(NSUInteger)capacity; //default is 50, 0 for no limit
- (CGLayerRef)cacheLayer;
- (void)updatContextWithCGLayer:(CGLayerRef)layer actionCount:(NSInteger)actionCount;
- (void)addContextWithCGLayer:(CGLayerRef)layer
                   actionCount:(NSInteger)actionCount;
- (BOOL)isFull;
- (BOOL)noLimit;
@end
