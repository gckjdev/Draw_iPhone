//
//  HBrushPointList.h
//  Draw
//
//  Created by 黄毅超 on 14-9-1.
//
//

@interface HBrushPointList : NSObject

@property (assign, nonatomic) float leftTopX;
@property (assign, nonatomic) float leftTopY;
@property (assign, nonatomic) float bottomRightX;
@property (assign, nonatomic) float bottomRightY;
@property (assign, nonatomic) float maxWidth;

- (CGRect)bounds;

- (float)getPointX:(int)index;
- (float)getPointY:(int)index;
- (float)getPointWidth:(int)index;
- (CGPoint)lastPoint;
- (int)count;
- (CGPoint)pointAtIndex:(int)index;
- (void)complete;

- (void)addPoint:(float)x y:(float)y width:(float)width;

- (void)createPointXList:(NSMutableArray**)pointXList
              pointYList:(NSMutableArray**)pointYList
               widthList:(NSMutableArray**)widthList;

- (void)createPointFloatXList:(CGFloat*)floatXList
                   floatYList:(CGFloat*)floatYList
                    widthList:(CGFloat*)widthList;


@end