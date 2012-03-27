//
//  CommonDialog.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SINGLE_BUTTON = 0,
    DOUBLE_BUTTON
}CommonDialogStyle;

@protocol CommonDialogDelegate <NSObject>
 @optional
- (void)clickOk;
- (void)clickBack;
@end

@interface CommonDialog : UIView {
    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIButton *oKButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;

@property (assign, nonatomic) id<CommonDialogDelegate> delegate;
+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle;
+ (CommonDialog *)createDialogwWithDelegate:(id<CommonDialogDelegate>)aDelegate withStyle:(CommonDialogStyle)aStyle;
@end
