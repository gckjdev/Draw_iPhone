//
//  PenEffectProtocol.h
//  Draw
//
//  Created by qqn_pipi on 13-1-19.
//
//

#import <Foundation/Foundation.h>

#define RELEASE_PATH(p)      if (p != NULL)  { CGPathRelease(p);  p = NULL; } 
#define MID_POINT(p1, p2)    ( CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5) )

@protocol PenEffectProtocol <NSObject>

- (void)constructPath:(NSArray*)pointList;
- (CGPathRef)penPath;
- (BOOL)hasPoint;

- (void)startAddPoint;
- (void)addPointIntoPath:(CGPoint)point;
- (void)finishAddPoint;

@end
