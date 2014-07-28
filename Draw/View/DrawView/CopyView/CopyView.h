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
@class PBStage;
@class PBUserStage;

@interface CopyView : SPUserResizableView<SPUserResizableViewDelegate, UIGestureRecognizerDelegate>

+ (CopyView*)createCopyView:(PPViewController*)superViewController
                  superView:(UIView*)superView
                    atPoint:(CGPoint)point
                     opusId:(NSString*)opusId
                  userStage:(PBUserStage*)userStage
                      stage:(PBStage*)stage;

- (void)enableMenu;
- (void)disableMenu;
- (UIImage*)image;
- (UIImage*)imageForCompare;

- (void)loadData:(PBUserStage*)userStage stage:(PBStage*)stage;

@end
