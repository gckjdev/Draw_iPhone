//
//  UserInfoCell.h
//  Draw
//
//  Created by  on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewCell.h"
#import "DrawFeed.h"
#import "StableView.h"

@interface UserInfoCell : PPTableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UILabel *nickLabel;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *signLabel;
@property (retain, nonatomic) IBOutlet UIView *lineView;

- (void)setCellInfo:(DrawFeed *)feed;
+ (NSString*)getCellIdentifier;

@end




