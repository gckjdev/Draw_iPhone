//
//  RopeView.h
//  Draw
//
//  Created by Gamy on 13-9-17.
//
//

#import <UIKit/UIKit.h>

@class RopeView;

typedef void (^FinishDragHandler)(RopeView *rope);

@interface RopeView : UIView<UIGestureRecognizerDelegate>
{
    UIImageView *_ropeImage;
}
@property(copy, nonatomic) FinishDragHandler finishHandler;

- (void)reset;
+ (id)ropeView;

@end
