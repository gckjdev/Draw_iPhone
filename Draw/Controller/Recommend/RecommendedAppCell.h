//
//  RecommendedAppCell.h
//  Travel
//
//  Created by 小涛 王 on 12-4-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "PPTableViewCell.h"
#import "HJManagedImageV.h"
@class RecommendApp;

@interface RecommendedAppCell : UITableViewCell <HJManagedImageVDelegate>

@property (retain, nonatomic) IBOutlet HJManagedImageV *imageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *briefIntroLabel;

- (void)setCellData:(RecommendApp*)app;
+ (RecommendedAppCell*)creatCell;
+ (NSString*)getCellIdentifier;

@end
