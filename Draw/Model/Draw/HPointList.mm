//
//  PointNode.m
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import "HPointList.h"
#import "Draw.pb.h"
#import "DrawUtils.h"
#include <vector>
#include <list>

using std::vector;
using std::list;

@interface HPointList ()
{
    vector<float> xList;
    vector<float> yList;

//    list<float> xList;
//    list<float> yList;

}

@end

@implementation HPointList

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)addPoint:(float)x y:(float)y
{
    xList.push_back(x);
    yList.push_back(y);
}

- (float)getPointX:(int)index
{
//    return xList.at(index);
    return xList[index];
}

- (float)getPointY:(int)index
{
//    return yList.at(index);
    return yList[index];
}

- (CGPoint)pointAtIndex:(int)index
{
//    return CGPointMake(xList.at(index), yList.at(index));
    return CGPointMake(xList[index], yList[index]);
}

- (int)count
{
    return xList.size();
}

- (void)createPointXList:(NSMutableArray**)pointXList pointYList:(NSMutableArray**)pointYList
{
    int size = xList.size();
    if (size > 0) {
        *pointXList = [[[NSMutableArray alloc] init] autorelease];
        *pointYList = [[[NSMutableArray alloc] init] autorelease];
        
        for (int i=0; i<size; i++){
            [*pointXList addObject:@(xList[i])];
            [*pointYList addObject:@(yList[i])];
//            [*pointXList addObject:@(xList.at(i))];
//            [*pointYList addObject:@(yList.at(i))];
        }
    }    
}

- (void)createPointFloatXList:(CGFloat*)floatXList floatYList:(CGFloat*)floatYList
{
    int size = xList.size();
    if (size > 0) {        
        for (int i=0; i<size; i++){
            floatXList[i] = xList[i];
            floatYList[i] = yList[i];
//            floatXList[i] = xList.at(i);
//            floatYList[i] = yList.at(i);
        }
    }
}

- (CGPoint)lastPoint
{
//    int index = xList.size();
//    if (index <= 0){
//        return ILLEGAL_POINT;
//    }
//    return CGPointMake(xList.at(index-1), yList.at(index-1));
    return CGPointMake(xList.back(), yList.back());
}

- (void)complete
{
    
    // performance vs. memory
    
//    vector<float> tmpX(xList);
//    vector<float> tmpY(yList);
//    
//    xList.swap(tmpX);
//    yList.swap(tmpY);
    
}

@end
