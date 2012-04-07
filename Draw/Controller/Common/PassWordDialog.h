//
//  PassWordDialog.h
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputDialog.h"
//@class PassWordDialog;

//@protocol PassWordDialog : InputDialog
//
//
//@end



@interface PassWordDialog : InputDialog
{
    
}
@property (retain, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (retain, nonatomic) IBOutlet UITextField *anotherPasswordTextField;
+ (PassWordDialog *)dialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate;
- (void)hideOldPasswordTextField;
@end
