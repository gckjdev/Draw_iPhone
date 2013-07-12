//
//  ShareActionView.h
//  Draw
//
//  Created by 王 小涛 on 13-7-4.
//
//

#import <UIKit/UIKit.h>

#import "CustomActionSheet.h"
#import "OpusActionManager.h"

@class ShareActionView;

@protocol ShareActionViewDelegate <NSObject>

- (void)shareActionView:(ShareActionView *)view didSelectAction:(int)action;

@end


@interface ShareActionView : UIView <CustomActionSheetDelegate>

- (id)initWithActions:(NSArray *)actions
             delegate:(id<ShareActionViewDelegate>)delegete;

- (void)displayInView:(UIView *)inView
               atView:(UIView*)atView;

@end
