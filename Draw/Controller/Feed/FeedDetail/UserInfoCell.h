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
//#import "FeedService.h"

@interface UserInfoCell : PPTableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UILabel *nickLabel;
@property (retain, nonatomic) IBOutlet UIView *avatarView;

- (void)setCellInfo:(DrawFeed *)feed;
+ (NSString*)getCellIdentifier;
@end




