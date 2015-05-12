//
//  CopyView.h
//  Draw
//
//  Created by qqn_pipi on 14-6-24.
//
//

#import <UIKit/UIKit.h>
#import "SPUserResizableView.h"
#import "DrawConstants.h"

@class PPViewController;
@class PBStage;
@class PBUserStage;

@interface CopyView : SPUserResizableView<SPUserResizableViewDelegate, UIGestureRecognizerDelegate>

+ (CopyView*)createCopyView:(PPViewController*)superViewController
                  superView:(UIView*)superView
                    atPoint:(CGPoint)point
                  referView:(UIView*)referView
                     opusId:(NSString*)opusId
                  userStage:(PBUserStage*)userStage
                      stage:(PBStage*)stage
                       type:(TargetType)type;

+ (CopyView*)createCopyView:(PPViewController*)superViewController
                  superView:(UIView*)superView
                    atPoint:(CGPoint)point
                  referView:(UIView*)referView
                      image:(UIImage*)image
                       type:(TargetType)type;

- (void)enableMenu;
- (void)disableMenu;
- (UIImage*)image;
- (UIImage*)imageForCompare;
- (void)setImage:(UIImage*)image;

- (void)loadData:(PBUserStage*)userStage stage:(PBStage*)stage;
- (BOOL)play;

@end
