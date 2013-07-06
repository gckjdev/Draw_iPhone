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
    
    ClipTypeRectangle = 1,
    ClipTypeEllipse = 2,
    ClipTypePolygon = 3,
    ClipTypeSmoothPath = 4,
    
}ClipType;

@class ShapeInfo;
@class Paint;

@interface ClipAction : DrawAction
{
//    BOOL _hasClipContext;
//    BOOL _hasUnClipContext;
}

//@property(nonatomic, assign)NSInteger clipTag;
@property(nonatomic, assign)ClipType clipType;

- (void)clipContext:(CGContextRef)context; //execute once.
//- (void)unClipContext:(CGContextRef)context;

+ (id)clipActionWithShape:(ShapeInfo *)shape;
+ (id)clipActionWithPaint:(Paint *)paint;
@end

