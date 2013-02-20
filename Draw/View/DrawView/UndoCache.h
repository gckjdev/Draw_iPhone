//
//  UndoCache.h
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import <Foundation/Foundation.h>


@interface UndoCache : NSObject

@property(nonatomic, assign, readonly)NSUInteger paintCount;
@property(nonatomic, assign, readonly)NSUInteger capacity;

- (id)initWithCapacity:(NSUInteger)capacity; //default is 50, 0 for no limit
- (CGLayerRef)cacheLayer;
- (void)updatContextWithCGLayer:(CGLayerRef)layer paintCount:(NSInteger)paintCount;
- (void)addContextWithCGLayer:(CGLayerRef)layer
                   paintCount:(NSInteger)paintCount;
- (BOOL)isFull;
- (BOOL)noLimit;
@end
