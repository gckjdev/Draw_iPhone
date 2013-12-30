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
#import "UIImageView+Extend.h"

@interface ContestCell()
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UIImageView *joinedImageView;
@property (retain, nonatomic) IBOutlet UILabel *contestNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *contestImageView;
@property (retain, nonatomic) IBOutlet UIImageView *labelBgImageView;

@end

@implementation ContestCell


- (void)dealloc {
    [_avatarView release];
    [_joinedImageView release];
    [_contestNameLabel release];
    [_leftTimeLabel release];
    [_bgImageView release];
    [_contestImageView release];
    [_labelBgImageView release];
    [super dealloc];
}

+ (id)createCell:(id)delegate{
    
    ContestCell *cell = [super createCell:delegate];
    cell.bgImageView.image = [ShareImageManager bubleImage];
    [cell.contestImageView.layer setCornerRadius:4];
    [cell.contestImageView setClipsToBounds:YES];
    [cell.labelBgImageView.layer setCornerRadius:4];
    [cell.labelBgImageView setClipsToBounds:YES];
    return cell;
}

+ (float)getCellHeight{
    
    return 111;
}

+ (NSString*)getCellIdentifier
{
    return @"ContestCell";
}

- (void)setCellInfo:(Contest *)contest{
    
    [self.avatarView setUrlString:contest.pbContest.group.medalImage];
    self.contestNameLabel.text = contest.pbContest.title;
    self.leftTimeLabel.text = [contest leftTime];
    [self.contestImageView setImageWithURL:[NSURL URLWithString:[contest contestUrl]]];
}

@end
