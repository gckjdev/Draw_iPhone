//
//  GroupCell.m
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "GroupCell.h"
#import "IconView.h"
//#import "GroupInfoView.h"
#import "GroupUIManager.h"
#import "GroupManager.h"
#import "GroupService.h"

@interface GroupCell()
@property(nonatomic, retain)GroupInfoView *infoView;
@end

@implementation GroupCell

- (void)updateView
{
    self.infoView = [GroupInfoView infoViewWithGroup:nil];
    self.infoView.delegate = self;
    [self.contentView addSubview:self.infoView];
    self.contentView.frame = self.bounds;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[GroupUIManager unfollowingGroupImage] forState:UIControlStateNormal];
    [button setImage:[GroupUIManager followedGroupImage] forState:UIControlStateSelected];

    [self.infoView setCustomButton:button];
}

+ (GroupCell *)createCell:(id)delegate
{
    GroupCell *cell = [GroupCell createViewWithXibIdentifier:[self getCellIdentifier] ofViewIndex:ISIPAD];
    [cell updateView];
    cell.delegate = delegate;
    return cell;
}

+ (CGFloat)getCellHeight
{
    return [GroupInfoView getViewHeight];
}

+ (NSString*)getCellIdentifier
{
    return @"GroupCell";
}


- (void)setCellInfo:(PBGroup *)group
{
    self.group = group;
    self.infoView.group = group;
    [self setNeedsLayout];
    
    
}

- (void)dealloc {
    PPRelease(_group);
    PPRelease(_infoView);
    [super dealloc];
}

- (void)layoutSubviews
{
    self.infoView.frame = self.bounds;
    _infoView.customButton.selected = [[GroupManager defaultManager] followedGroup:_group.groupId];
}

- (void)groupInfoView:(GroupInfoView *)infoView didClickCustomButton:(UIButton *)button
{
    
    if (self.delegate) {
        if (button.isSelected) {
            //UNFollow
            if ([self.delegate respondsToSelector:@selector(groupCell:goFollowGroup:)]) {
                [self.delegate groupCell:self goFollowGroup:_group];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(groupCell:goUnfollowGroup:)]) {
                [self.delegate groupCell:self goUnfollowGroup:_group];
            }
        }
        
    }
}

@end
