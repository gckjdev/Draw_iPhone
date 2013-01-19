//
//  PenEffectProtocol.h
//  Draw
//
//  Created by qqn_pipi on 13-1-19.
//
//

#import <Foundation/Foundation.h>

@protocol PenEffectProtocol <NSObject>

- (void)constructPath:(NSArray*)pointList;
- (CGPathRef)penPath;

- (void)addPointIntoPath:(CGPoint)point;
- (void)finishPoint;

@end
