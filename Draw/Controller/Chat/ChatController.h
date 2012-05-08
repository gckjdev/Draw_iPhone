//
//  ChatController.h
//  Draw
//
//  Created by 小涛 王 on 12-5-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "PPTableViewController.h"

@class AvatarView;

@interface ChatController : PPTableViewController
@property (retain, nonatomic) IBOutlet UIView *headImageHolderView;

@property (retain, nonatomic) IBOutlet AvatarView *headView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *sexLabel;
@property (retain, nonatomic) IBOutlet UILabel *cityLabel;
@property (retain, nonatomic) IBOutlet UIImageView *microBlogImageView;

@property (retain, nonatomic) IBOutlet UIScrollView *expressionScrollView;
@property (retain, nonatomic) IBOutlet UITableView *messageTableView;

@end
