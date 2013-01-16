//
//  ChatDetailCell.h
//  Draw
//
//  Created by haodong qiu on 12年6月19日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"
#import "ShowDrawView.h"
#import "StableView.h"

@class PPViewController;
@class PPMessage;
@class ShowDrawView;
@class MessageStat;
@class MyFriend;

@protocol ChatDetailCellDelegate <NSObject>

@optional

- (void)clickMessage:(PPMessage *)message 
         withDrawActionList:(NSArray *)drawActionList;

- (void)clickMessage:(PPMessage *)message 
         withImageURL:(NSString *)imageURL;

- (void)didLongClickMessage:(PPMessage *)message;

- (void)showFriendProfile:(MyFriend *)aFriend;

@end


@interface ChatDetailCell : PPTableViewCell<ShowDrawViewDelegate>
{
    
}

@property (retain, nonatomic) IBOutlet UIImageView *avatarView;
@property (retain, nonatomic) IBOutlet UIButton *timeButton;
@property (retain, nonatomic) IBOutlet UIButton *avatarButton;
@property (retain, nonatomic) IBOutlet UIButton *contentButton;
@property (retain, nonatomic) IBOutlet ShowDrawView *showDrawView;
//@property (retain, nonatomic) PPViewController *superController;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (retain, nonatomic) IBOutlet UIImageView *failureView;

+ (id)createCell:(id<ChatDetailCellDelegate>)delegate isReceive:(BOOL)isRecevie;
+ (NSString*)getCellIdentifierIsReceive:(BOOL)isRecevie;

- (IBAction)clickContentButton:(id)sender;
- (IBAction)clickAvatarButton:(id)sender;




+ (CGFloat)getCellHeight:(PPMessage *)message 
                showTime:(BOOL)showTime;
- (void)setCellWithMessageStat:(MessageStat *)messageStat 
                       message:(PPMessage *)message 
                     indexPath:(NSIndexPath *)indexPath 
                      showTime:(BOOL)showTime;

@end
