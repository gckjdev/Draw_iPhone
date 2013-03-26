//
//  CanvasRectBox.h
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import <UIKit/UIKit.h>
#import "CanvasRect.h"

@class CanvasRectBox;


@protocol CanvasRectBoxDelegate <NSObject>

- (void)canvasBox:(CanvasRectBox *)box didSelectedRect:(CanvasRect *)rect;

@end


@interface CanvasRectBox : UIView

+ (id)canvasRectBoxWithDelegate:(id<CanvasRectBoxDelegate>)delegate;

- (void)setSelectedRect:(CanvasRectStyle)style;

@end
