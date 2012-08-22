//
//  ChatView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-20.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomPageControl.h"
#import "ChatViewCell.h"
#import "CMPopTipView.h"

@protocol ChatViewDelegate <NSObject>

@optional
- (void)didClickExepression:(NSString *)key;
- (void)didClickMessage:(NSString *)message;

@end


@interface ChatView : UIView <UITableViewDataSource, UITableViewDelegate, UICustomPageControlDelegate, ChatViewCellDelegate>

@property (assign, nonatomic) id<ChatViewDelegate> delegate;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection;

- (void)dismissAnimated:(BOOL)animated;

@end
