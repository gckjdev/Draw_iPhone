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

- (float)getPointX:(int)index
{
    return xList[index];
}

- (float)getPointY:(int)index
{
    return yList[index];
}

- (float)getPointWidth:(int)index
{
    return widthList[index];
}

- (float)getPointRandom:(int)index
{
    return randomList[index];
}

- (CGPoint)pointAtIndex:(int)index
{
    return CGPointMake(xList[index], yList[index]);
}

- (int)count
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

#define BRUSH_RECT_MARGIN (0)

- (CGRect)bounds
{
    //若不是正在画的笔画，则进入该条件判断，计算整个list的bounds
    if (_leftTopX == MAX_TOP
        && _leftTopY == MAX_TOP
        && _bottomRightX == -MAX_TOP
        && _bottomRightY == -MAX_TOP){
        
        // calculate from point list
        int count = xList.size();
        float x, y, width;
        for (int i=0; i<count; i++){
            x = xList[i];
            y = yList[i];
            width = widthList[i];
            
            _leftTopX = _leftTopX < x ? _leftTopX : x;
            _leftTopY = _leftTopY < y ? _leftTopY : y;
            _bottomRightX = _bottomRightX > x ? _bottomRightX : x;
            _bottomRightY = _bottomRightY > y ? _bottomRightY : y;
            _maxWidth =  width;
        }
    }
    
    //若为正在画的笔画，则由于addPoint中已经有实时计算的左上，右下两点位置，估直接得出一个rect
    CGRect rect = CGRectMake(_leftTopX - BRUSH_RECT_MARGIN ,
                      _leftTopY - BRUSH_RECT_MARGIN ,
                      _bottomRightX - _leftTopX + BRUSH_RECT_MARGIN,
                      _bottomRightY - _leftTopY + BRUSH_RECT_MARGIN);
    
    return rect;
}

- (void)addPoint:(float)x y:(float)y width:(float)width random:(int)random
{
    _leftTopX = _leftTopX < x ? _leftTopX : x;
    _leftTopY = _leftTopY < y ? _leftTopY : y;
    _bottomRightX = _bottomRightX > x ? _bottomRightX : x;
    _bottomRightY = _bottomRightY > y ? _bottomRightY : y;
    _maxWidth =  width;
    
//    PPDebug(@"(%f,%f)(%f,%f)",_leftTopX,_leftTopY,_bottomRightX,_bottomRightY);
    
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
    int size = xList.size();
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

- (void)createPointFloatXList:(CGFloat*)floatXList
                   floatYList:(CGFloat*)floatYList
                    widthList:(CGFloat*)floatWidthList
                   randomList:(int32_t*)randomValueList
{
    int size = xList.size();
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
