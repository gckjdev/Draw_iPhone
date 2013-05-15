//
//  ChatDetailController.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "ChatService.h"
#import "OfflineDrawViewController.h"
#import "ChatDetailCell.h"
#import "UserLocationController.h"
#import "PhotoDrawSheet.h"

@class MessageStat;
@class PPMessage;

@protocol ChatDetailControllerDelegate <NSObject>

@optional
- (void)didMessageStat:(MessageStat *)messageStat createNewMessage:(PPMessage *)message;

@end

@interface ChatDetailController : PPTableViewController<ChatServiceDelegate, UITextViewDelegate, OfflineDrawDelegate, ChatDetailCellDelegate, UserLocationControllerDelegate, UIActionSheetDelegate, PhotoDrawSheetDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *inputBackgroundView;
@property (retain, nonatomic) IBOutlet UITextView *inputTextView;
@property (retain, nonatomic) IBOutlet UIImageView *inputTextBackgroundImage;
@property (retain, nonatomic) IBOutlet UIButton *refreshButton;
@property (assign, nonatomic) id<ChatDetailControllerDelegate> delegate;
- (IBAction)clickRefresh:(id)sender;

- (IBAction)clickGraffitiButton:(id)sender; 
- (void)loadNewMessage:(BOOL)showActivity;
- (id)initWithMessageStat:(MessageStat *)messageStat;
- (NSString *)fid;
@end
