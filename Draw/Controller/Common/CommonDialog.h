//
//  CommonDialog.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommonDialogDelegate <NSObject>
 @optional
- (void)clickOk;
- (void)clickBack;
@end

@interface CommonDialog : UIView {
    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (assign, nonatomic) id<CommonDialogDelegate> delegate;
+ (CommonDialog *)createDialog;
+ (CommonDialog *)createDialogwWithDelegate:(id<CommonDialogDelegate>)aDelegate;
@end
