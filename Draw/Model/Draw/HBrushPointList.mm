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
}

@end

@implementation HBrushPointList

- (id)init
{
    self = [super init];
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

- (CGRect)bounds
{
    if (_leftTopX == 0 && _leftTopY == 0 && _bottomRightX == 0 && _bottomRightY == 0){
        // calculate from point list
        int count = xList.size();
        float x, y, width;
        for (int i=0; i<count; i++){
            x = xList[i];
            y = yList[i];
            width = widthList[i];
            
            _leftTopX = _leftTopX < x ? _leftTopX - width/2: x - width/2;
            _leftTopY = _leftTopY < y ? _leftTopY - width/2: y - width/2;
            _bottomRightX = _bottomRightX > x ? _bottomRightX + width/2: x + width/2;
            _bottomRightY = _bottomRightY > y ? _bottomRightY + width/2: y + width/2;
        }
    }

    return CGRectMake(_leftTopX , _leftTopY, _bottomRightX - _leftTopX, _bottomRightY - _leftTopY);
}

- (void)addPoint:(float)x y:(float)y width:(float)width;
{
    _leftTopX = _leftTopX < x ? _leftTopX - width/2: x - width/2;
    _leftTopY = _leftTopY < y ? _leftTopY - width/2: y - width/2;
    _bottomRightX = _bottomRightX > x ? _bottomRightX + width/2: x + width/2;
    _bottomRightY = _bottomRightY > y ? _bottomRightY + width/2: y + width/2;
    
    xList.push_back(x);
    yList.push_back(y);
    widthList.push_back(width);
}

- (void)createPointXList:(NSMutableArray**)pointXList
              pointYList:(NSMutableArray**)pointYList
               widthList:(NSMutableArray**)pointWList;
{
    int size = xList.size();
    if (size > 0) {
        *pointXList = [[[NSMutableArray alloc] init] autorelease];
        *pointYList = [[[NSMutableArray alloc] init] autorelease];
        *pointWList = [[[NSMutableArray alloc] init] autorelease];
        
        for (int i=0; i<size; i++){
            [*pointXList addObject:@(xList[i])];
            [*pointYList addObject:@(yList[i])];
            [*pointWList addObject:@(widthList[i])];
        }
    }
}

- (void)createPointFloatXList:(CGFloat*)floatXList
                   floatYList:(CGFloat*)floatYList
                    widthList:(CGFloat*)floatWidthList
{
    int size = xList.size();
    if (size > 0) {
        for (int i=0; i<size; i++){
            floatXList[i] = xList[i];
            floatYList[i] = yList[i];
            floatWidthList[i] = widthList[i];
        }
    }
}


@end
