//
//  ChatView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-20.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewCell.h"
#import "CMPopTipView.h"
#import "UICustomPageControl.h"
#import "UIPlaceholderTextView.h"
#import "TextViewExt.h"

@protocol ChatViewDelegate <NSObject>

@optional
- (void)didClickCloseButton;
- (void)didClickExepression:(NSString *)key;
- (void)didClickMessage:(CommonChatMessage *)message;

@end


@interface ChatView : UIButton <UITableViewDataSource, UITableViewDelegate, ChatViewCellDelegate, CMPopTipViewDelegate, UITextViewDelegate>

@property (assign, nonatomic) id<ChatViewDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIScrollView *expressionsHolderView;
@property (retain, nonatomic) IBOutlet UICustomPageControl *pageController;

@property (retain, nonatomic) IBOutlet UITableView *messagesHolderView;
@property (retain, nonatomic) IBOutlet UIPlaceholderTextView *inputTextView;
@property (retain, nonatomic) IBOutlet UIImageView *inputTextViewBgImageView;

+ (id)createChatView;
- (void)loadContent;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
       aboveSubView:(UIView *)siblingSubview
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection;

- (void)dismissAnimated:(BOOL)animated;

@end
