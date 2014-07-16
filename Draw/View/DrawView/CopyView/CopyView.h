//
//  CopyView.h
//  Draw
//
//  Created by qqn_pipi on 14-6-24.
//
//

#import <UIKit/UIKit.h>
#import "SPUserResizableView.h"

@class PPViewController;

@interface CopyView : SPUserResizableView<SPUserResizableViewDelegate, UIGestureRecognizerDelegate>

+ (CopyView*)createCopyView:(PPViewController*)superViewController
                  superView:(UIView*)superView
                    atPoint:(CGPoint)point
                     opusId:(NSString*)opusId;

- (void)enableMenu;
- (void)disableMenu;


@end
