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
#import "StableView.h"
#import "IconView.h"
#import "GroupUIManager.h"

@interface ContestCell()
@property (retain, nonatomic) IBOutlet GroupIconView *groupIconView;
@property (retain, nonatomic) IBOutlet UIImageView *joinedImageView;
@property (retain, nonatomic) IBOutlet UILabel *contestNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *contestImageView;
@property (retain, nonatomic) IBOutlet UIImageView *labelBgImageView;

@property (retain, nonatomic) Contest *contest;

@end

@implementation ContestCell


- (void)dealloc {
    [_groupIconView release];
    [_joinedImageView release];
    [_contestNameLabel release];
    [_leftTimeLabel release];
    [_bgImageView release];
    [_contestImageView release];
    [_labelBgImageView release];
    [_contest release];
    [super dealloc];
}

+ (id)createCell:(id)delegate{
    
    ContestCell *cell = [super createCell:nil];
    cell.bgImageView.image = [ShareImageManager bubleImage];
    [cell.contestImageView.layer setCornerRadius:4];
    [cell.contestImageView setClipsToBounds:YES];
    [cell.labelBgImageView.layer setCornerRadius:4];
    [cell.labelBgImageView setClipsToBounds:YES];
    cell.delegate = delegate;
    
    [cell.contestImageView addTapGuestureWithTarget:cell selector:@selector(didClickOnContestImageView)];
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
    
    self.contest = contest;
    
    [self.groupIconView setGroupId:[contest contestId]];
    
    [self.groupIconView setImageURL:[contest groupMedalImageUrl] placeholderImage:[GroupUIManager defaultGroupMedal]];
    
    __block typeof (self)bself = self;
    [self.groupIconView setClickHandler:^(IconView *iconView){
        
        if ([bself.delegate respondsToSelector:@selector(didClickGroup:)]) {
            [bself.delegate didClickGroup:contest.pbGroup];
        }
    }];
    
    
    self.contestNameLabel.text = contest.pbContest.title;
    self.leftTimeLabel.text = [contest leftTime];
    [self.contestImageView setImageWithURL:[NSURL URLWithString:[contest contestUrl]]];
}

- (void)didClickOnContestImageView{
    
    if ([delegate respondsToSelector:@selector(didClickContest:)]) {
        [delegate didClickContest:self.contest];
    }
}

@end