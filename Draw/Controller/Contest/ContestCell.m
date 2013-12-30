//
//  ContestCell.m
//  Draw
//
//  Created by 王 小涛 on 13-12-24.
//
//

#import "ContestCell.h"
#import "StableView.h"
#import "Contest.h"
#import "UIImageView+WebCache.h"

@interface ContestCell()
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UIImageView *joinedImageView;
@property (retain, nonatomic) IBOutlet UILabel *contestNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *leftTimeLabel;

@end

@implementation ContestCell


- (void)dealloc {
    [_avatarView release];
    [_joinedImageView release];
    [_contestNameLabel release];
    [_leftTimeLabel release];
    [super dealloc];
}

+ (float)getCellHeight{
    
    return 109;
}

+ (NSString*)getCellIdentifier
{
    return @"ContestCell";
}

- (void)setCellInfo:(Contest *)contest{
    
    [self.avatarView setUrlString:contest.pbGroup.medalImage];
    self.contestNameLabel.text = contest.pbContest.title;
    self.leftTimeLabel.text = [contest leftTime];
}

@end
