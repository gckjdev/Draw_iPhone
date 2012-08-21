//
//  ChatView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-20.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatViewDelegate <NSObject>

@optional
- (void)didClickExepression:(UIImage *)image;
- (void)didClickMessage:(NSString *)message;

@end


@interface ChatView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) id<ChatViewDelegate> delegate;

- (id)init;


@end
