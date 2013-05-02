//
//  ShapeInfo.h
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import "ItemType.h"
#import "DrawColor.h"

typedef enum{
    ShapeTypeNone = 0,
    ShapeTypeBeeline = 1,
    ShapeTypeRectangle,
    ShapeTypeEllipse,
    ShapeTypeTriangle,
    ShapeTypeStar,
}ShapeType;

//@class PBShapeInfo;
@class DrawColor;
@class PBDrawAction_Builder;

@interface ShapeInfo : NSObject
{
    
}
@property(nonatomic, assign)CGPoint startPoint;
@property(nonatomic, assign)CGPoint endPoint;

@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)ShapeType type;
@property(nonatomic, assign)CGFloat width;

@property(nonatomic, retain)DrawColor *color;


+ (UIImage *)shapeImageForShapeType:(ShapeType)type;

+ (id)shapeWithType:(ShapeType) type penType:(ItemType)penType width:(CGFloat)with color:(DrawColor *)color;
- (void)drawInContext:(CGContextRef)context;
- (CGRect)rect;
- (void)setPointsWithPointComponent:(NSArray *)pointComponent;
- (void)setPointsWithPointComponentC:(float*)floatList listCount:(int)listCount;
- (NSArray *)rectComponent;
- (CGRect)redrawRect;
- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder;
@end
