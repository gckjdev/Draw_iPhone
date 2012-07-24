//
//  RecommendedAppsControllerViewController.h
//  Travel
//
//  Created by 小涛 王 on 12-5-5.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"

#define RECOMMENDED_APP     @"精彩应用推荐"

@interface RecommendedAppsController : PPTableViewController
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end
