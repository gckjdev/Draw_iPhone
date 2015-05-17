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

- (CGRect)pointListBounds;

- (float)getPointX:(NSInteger)index;
- (float)getPointY:(NSInteger)index;
- (float)getPointWidth:(NSInteger)index;
- (float)getPointRandom:(NSInteger)index;
- (CGPoint)lastPoint;
- (NSInteger)count;
- (CGPoint)pointAtIndex:(NSInteger)index;
- (void)complete;

//dynamic calculation of bounding rect points
- (void)initBoundingRectWithPointX:(CGFloat)x
                            PointY:(CGFloat)y
                          andWidth:(CGFloat)width;
- (void)updateBoundingRectWithPointX:(CGFloat)x
                              PointY:(CGFloat)y
                            andWidth:(CGFloat)width;

//add point to list for every sampling
- (void)addPointX:(float)x
           PointY:(float)y
       PointWidth:(float)width
      PointRandom:(int)random;

- (void)createPointXList:(NSMutableArray**)pointXList
              pointYList:(NSMutableArray**)pointYList
               widthList:(NSMutableArray**)widthList
              randomList:(NSMutableArray**)randomList;

- (void)createPointFloatXList:(float*)floatXList
                   floatYList:(float*)floatYList
                    widthList:(float*)widthList
                   randomList:(int32_t*)randomList;


@end
