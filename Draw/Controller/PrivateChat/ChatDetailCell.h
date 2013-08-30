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


- (void)clickMessage:(PPMessage *)message;

- (void)didLongClickMessage:(PPMessage *)message;

- (void)didMessage:(PPMessage *)message loadImage:(UIImage *)image;

@end


@interface ChatDetailCell : PPTableViewCell<ShowDrawViewDelegate, SDWebImageManagerDelegate>
{
    
}

@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UIButton *timeButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (retain, nonatomic) IBOutlet UIImageView *failureView;
@property (retain, nonatomic) IBOutlet UIImageView *imgView;
@property (retain, nonatomic) IBOutlet UILabel *msgLabel;
@property (retain, nonatomic) IBOutlet UIButton *holderView;

+ (id)createCell:(id<ChatDetailCellDelegate>)delegate;
+ (NSString *)getCellIdentifier;

+ (CGFloat)getCellHeight:(PPMessage *)message 
                showTime:(BOOL)showTime;

- (void)setCellWithMessageStat:(MessageStat *)messageStat 
                       message:(PPMessage *)message 
                     indexPath:(NSIndexPath *)indexPath 
                      showTime:(BOOL)showTime;

@end
