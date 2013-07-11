//
//  SettingAction.h
//  Draw
//
//  Created by gamy on 13-6-5.
//
//

#import "DrawAction.h"
//#import "PathConstructor.h"

typedef enum{
    ClipTypeNo = 0,
    ClipTypeRectangle = 1,
    ClipTypeEllipse = 2,
    ClipTypePolygon = 3,
    ClipTypeSmoothPath = 4,
    
}ClipType;

@class ShapeInfo;
@class Paint;

@interface ClipAction : DrawAction
{
    NSUInteger addPointTimes;
}

@property(nonatomic, retain)Paint *paint;
@property(nonatomic, retain)ShapeInfo *shape;
@property(nonatomic, assign)ClipType clipType;

- (void)clipContext:(CGContextRef)context; //execute once.

+ (id)clipActionWithShape:(ShapeInfo *)shape;
+ (id)clipActionWithPaint:(Paint *)paint;

- (CGRect)showClipInContext:(CGContextRef)context inRect:(CGRect)rect;

- (CGRect)pathRect;

@end

