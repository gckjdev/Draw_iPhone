//
//  ShapeBox.h
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import <UIKit/UIKit.h>
#import "ShapeInfo.h"

@class ShapeBox;


@protocol ShapeBoxDelegate <NSObject>

@optional
- (void)shapeBox:(ShapeBox *)shapeBox didSelectShapeType:(ShapeType)type;

@end


@interface ShapeBox : UIView

@end
