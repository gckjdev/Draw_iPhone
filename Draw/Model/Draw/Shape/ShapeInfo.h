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
    ShapeTypeImageBasicStart = 1,
    ShapeTypeBeeline = 1,
    ShapeTypeRectangle,
    ShapeTypeEllipse,
    ShapeTypeTriangle,
    ShapeTypeStar,
    ShapeTypeRoundRect,
    
    ShapeTypeImageBasicEnd,

    ShapeTypeImageStart = 1000,
    
    ShapeTypeImageNatureStart = 1000,
    ShapeTypeImageNatureEnd = 1099,

    ShapeTypeImageAnimalStart = 1100,
    ShapeTypeImageAnimalEnd = 1199,
    
    ShapeTypeImageShapeStart = 1200,
    ShapeTypeImageShapeEnd = 1299,
    
    ShapeTypeImageStuffStart = 1300,
    ShapeTypeImageStuffEnd = 1399,

    ShapeTypeImageSignStart = 1400,
    ShapeTypeImageSignEnd = 1499,
    
    ShapeTypeImagePlantStart = 1500,
    ShapeTypeImagePlantEnd = 1599,


    
    ShapeTypeImageEnd = 9999,
    
    
}ShapeType;

//@class PBShapeInfo;
@class DrawColor;
@class PBDrawAction_Builder;

@interface ShapeInfo : NSObject
{
    ShapeType _type;
    CGPathRef _path;
    CGRect _redrawRect;
    BOOL _stroke;    
}
@property(nonatomic, assign)CGPoint startPoint;
@property(nonatomic, assign)CGPoint endPoint;

@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)ShapeType type;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign, getter = isStroke)BOOL stroke;

@property(nonatomic, retain)DrawColor *color;


//+ (UIImage *)shapeImageForShapeType:(ShapeType)type;

+ (id)shapeWithType:(ShapeType) type penType:(ItemType)penType width:(CGFloat)with color:(DrawColor *)color;
- (void)drawInContext:(CGContextRef)context;
- (CGRect)rect;
- (void)setPointsWithPointComponent:(NSArray *)pointComponent;
- (void)setPointsWithPointComponentC:(float*)floatList listCount:(int)listCount;
- (NSArray *)rectComponent;
- (CGRect)redrawRect;
- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder;
- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC;

- (CGPathRef)path;
- (BOOL)isBasicShape;
//- (BOOL)isStroke;
@end



@interface ImageShapeInfo : ShapeInfo

- (id)initWithCGPath:(CGPathRef)path;

@end

