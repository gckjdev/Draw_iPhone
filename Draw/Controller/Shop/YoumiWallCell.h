//
//  YoumiWallCell.h
//  Draw
//
//  Created by  on 12-6-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "HJManagedImageV.h"

@interface YoumiWallCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UILabel *appNameLabel;

@property (retain, nonatomic) IBOutlet UILabel *rewardDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *rewardCoinsLabel;
@property (retain, nonatomic) IBOutlet HJManagedImageV *appImageView;

+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;

@end
