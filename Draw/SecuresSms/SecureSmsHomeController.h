//
//  SecureSmsHomeController.h
//  Draw
//
//  Created by haodong on 13-5-21.
//
//

#import "PPViewController.h"
#import "InputDialog.h"

typedef enum
{
    PureChatTypeSecureSms = 1,
    PureChatTypeCallTrack = 2,
} PureChatType;

@interface SecureSmsHomeController : PPViewController<InputDialogDelegate>
@property (retain, nonatomic) IBOutlet UIButton *chatButton;
@property (retain, nonatomic) IBOutlet UIButton *friendsButton;
@property (retain, nonatomic) IBOutlet UIButton *meButton;
@property (retain, nonatomic) IBOutlet UIButton *supportButton;

- (id)initWithType:(PureChatType)type;

- (IBAction)clickChatButton:(id)sender;
- (IBAction)clickFriendsButton:(id)sender;
- (IBAction)clickMeButton:(id)sender;
- (IBAction)clickSupportButton:(id)sender;

- (void)showInputView:(NSString *)placeholder;

@end
