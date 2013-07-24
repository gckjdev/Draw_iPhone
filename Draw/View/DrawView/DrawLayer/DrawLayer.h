//
//  DrawLayer.h
//  TestCodePool
//
//  Created by gamy on 13-7-22.
//  Copyright (c) 2013年 orange. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ItemType.h"
#import "ShapeInfo.h"

@interface DrawInfo : NSObject

@property(nonatomic, assign)CGFloat alpha;
@property(nonatomic, assign)CGFloat penWidth;

@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)ShapeType shapeType;

@property(nonatomic, retain)DrawColor *penColor;
@property(nonatomic, retain)DrawColor *bgColor;


@end



@class CacheDrawManager;
@class DrawAction;

@interface DrawLayer : CALayer
{
    
}


@property(nonatomic, retain)DrawInfo *drawInfo;
@property(nonatomic, retain)CacheDrawManager *cdManager;
@property(nonatomic, retain)NSMutableArray *drawActionList;
@property(nonatomic, assign)NSUInteger tag;
@property(nonatomic, copy)NSString *name;

@end
