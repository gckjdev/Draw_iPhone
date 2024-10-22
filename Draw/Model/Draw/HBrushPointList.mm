//
//  HBrushPointList.m
//  Draw
//
//  Created by 黄毅超 on 14-9-1.
//
//

#import "HBrushPointList.h"
#import "Draw.pb.h"
#import "DrawUtils.h"

#include <vector>
#include <list>

using std::vector;
using std::list;

@interface HBrushPointList()
{
    vector<float> xList;
    vector<float> yList;
    vector<float> widthList;
    vector<int> randomList;
}

@end

#define MAX_TOP     (999999)

@implementation HBrushPointList

- (id)init
{
    self = [super init];
    if (self){
        _leftTopX = MAX_TOP;
        _leftTopY = MAX_TOP;
        _bottomRightX = - MAX_TOP;
        _bottomRightY = - MAX_TOP;
        _maxWidth = 0;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (float)getPointX:(NSInteger)index
{
    return xList[index];
}

- (float)getPointY:(NSInteger)index
{
    return yList[index];
}

- (float)getPointWidth:(NSInteger)index
{
    return widthList[index];
}

- (float)getPointRandom:(NSInteger)index
{
    return randomList[index];
}

- (CGPoint)pointAtIndex:(NSInteger)index
{
    return CGPointMake(xList[index], yList[index]);
}

- (NSInteger)count
{
    return xList.size();
}

- (CGPoint)lastPoint
{
    return CGPointMake(xList.back(), yList.back());
}

- (void)complete
{
}


- (CGRect)pointListBounds
{
    //由于addPoint中已经有实时计算的左上，右下两点位置，故而直接得出一个rect
    CGRect rect = CGRectMake(_leftTopX,_leftTopY,
                             _bottomRightX-_leftTopX,
                             _bottomRightY-_leftTopY);
    
    return rect;
}

- (void)initBoundingRectWithPointX:(CGFloat)x
                            PointY:(CGFloat)y
                          andWidth:(CGFloat)width
{
    CGFloat width_half = width/2;
    self.leftTopX = x-width_half;
    self.leftTopY = y-width_half;
    self.bottomRightX = x+width_half;
    self.bottomRightY = y+width_half;
}

- (void)updateBoundingRectWithPointX:(CGFloat)x
                              PointY:(CGFloat)y
                            andWidth:(CGFloat)width
{
    CGFloat width_half = width/2;
    self.leftTopX = x-width_half < self.leftTopX? x-width_half:self.leftTopX;
    self.leftTopY = y-width_half < self.leftTopY? y-width_half:self.leftTopY;
    self.bottomRightX = x+width_half > self.bottomRightX? x+width_half:self.bottomRightX;
    self.bottomRightY = y+width_half > self.bottomRightY? y+width_half:self.bottomRightY;
}


- (void)addPointX:(float)x
           PointY:(float)y
       PointWidth:(float)width
      PointRandom:(int)random
{
    xList.push_back(x);
    yList.push_back(y);
    widthList.push_back(width);
    randomList.push_back(random);
}

- (void)createPointXList:(NSMutableArray**)pointXList
              pointYList:(NSMutableArray**)pointYList
               widthList:(NSMutableArray**)pointWList
              randomList:(NSMutableArray**)randomValueList;
{
    size_t size = xList.size();
    if (size > 0) {
        *pointXList = [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
        *pointYList = [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
        *pointWList = [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
        *randomValueList = [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
        
        for (int i=0; i<size; i++){
            [*pointXList addObject:@(xList[i])];
            [*pointYList addObject:@(yList[i])];
            [*pointWList addObject:@(widthList[i])];
            [*randomValueList addObject:@(randomList[i])];
        }
    }
}

- (void)createPointFloatXList:(float*)floatXList
                   floatYList:(float*)floatYList
                    widthList:(float*)floatWidthList
                   randomList:(int32_t*)randomValueList
{
    size_t size = xList.size();
    if (size > 0) {
        for (int i=0; i<size; i++){
            floatXList[i] = xList[i];
            floatYList[i] = yList[i];
            floatWidthList[i] = widthList[i];
            randomValueList[i] = randomList[i];
        }
    }
}


@end
