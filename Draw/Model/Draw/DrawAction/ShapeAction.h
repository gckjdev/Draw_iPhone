//
//  ShapeAction.h
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

//#import "DrawAction.h"

#import "DrawAction.h"

@class ShapeInfo;
@class DrawAction;

@interface ShapeAction : DrawAction
{
    
}

@property(nonatomic, retain)ShapeInfo *shape;
+ (id)shapeActionWithShape:(ShapeInfo *)shape;

@end
