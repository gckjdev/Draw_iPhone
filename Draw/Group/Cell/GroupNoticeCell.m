//
//  GroupNoticeCell.m
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import "GroupNoticeCell.h"
#import "GroupModelExt.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"

@implementation GroupNoticeCell

- (void)updateView
{
    [self.notice setFont:CELL_NICK_FONT];
    [self.message setFont:CELL_CONTENT_FONT];
    [self.timestamp setFont:CELL_SMALLTEXT_FONT];
    [self.notice setTextColor:COLOR_BROWN];
    [self.message setTextColor:COLOR_BROWN];
    [self.timestamp setTextColor:COLOR_BROWN];
    [self.notice setNumberOfLines:2];
    [self.message setNumberOfLines:1];
    [self.notice setLineBreakMode:NSLineBreakByCharWrapping];
    [self.message setLineBreakMode:NSLineBreakByCharWrapping];
    [self.avatar setDelegate:self];
}

- (void)didClickOnAvatarView:(AvatarView *)avatarView
{
    PPViewController *controller = (id)[self theViewController];
    ViewUserDetail *detail = [ViewUserDetail viewUserDetailWithUser:self.groupNotice.publisher];
    [UserDetailViewController presentUserDetail:detail inViewController:controller];
}

+ (id)createCell:(id)delegate
{
    GroupNoticeCell *cell = [self createViewWithXibIdentifier:@"GroupNoticeCell" ofViewIndex:ISIPAD];
    cell.delegate = delegate;
    [cell updateView];
    return cell;
}
+ (NSString*)getCellIdentifier
{
    return @"GroupNoticeCell";
}
+ (CGFloat)getCellHeight
{
    return (ISIPAD ? 176 : 97);
}

- (void)setCellInfo:(PBGroupNotice *)notice
{
    self.groupNotice = notice;
    [self.notice setText:notice.desc];
    [self.message setText:notice.msg];
    [self.timestamp setText:notice.createDateString];
    [self.avatar setUser:notice.publisher];
//    [self setNeedsLayout];
}



#define LABEL_Y_INSET (ISIPAD?9:4)
#define TIMELABEL_HEIGHT (ISIPAD?30:16)
#define MIN_HEIGHT (ISIPAD?140:73)
#define LABEL_WIDTH (ISIPAD?550:225)


+ (CGFloat)getCellHeightByNotice:(PBGroupNotice *)groupNotice
{
    if([groupNotice.message length] > 0){
        return [self getCellHeight];
    }
    return (ISIPAD ? 150: 80);
}


- (void)dealloc {
    [_avatar release];
    [_notice release];
    [_message release];
    [_timestamp release];
    PPRelease(_groupNotice);
    [super dealloc];
}
@end
