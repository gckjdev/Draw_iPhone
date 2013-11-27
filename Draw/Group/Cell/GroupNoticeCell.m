//
//  GroupNoticeCell.m
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import "GroupNoticeCell.h"
#import "GroupModelExt.h"

@implementation GroupNoticeCell

- (void)updateView
{
    [self.notice setFont:CELL_NICK_FONT];
    [self.message setFont:CELL_CONTENT_FONT];
    [self.timestamp setFont:CELL_SMALLTEXT_FONT];
    [self.notice setTextColor:COLOR_BROWN];
    [self.message setTextColor:COLOR_BROWN];
    [self.timestamp setTextColor:COLOR_BROWN];
    [self.notice setNumberOfLines:0];
    [self.message setNumberOfLines:0];
    [self.notice setLineBreakMode:NSLineBreakByCharWrapping];
    [self.message setLineBreakMode:NSLineBreakByCharWrapping];
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
    return 44;
}

- (void)setCellInfo:(PBGroupNotice *)notice
{
    self.groupNotice = notice;
    [self.notice setText:notice.desc];
    [self.message setText:notice.msg];
    [self.timestamp setText:notice.createDateString];
    [self.avatar setUser:notice.publisher];
    [self setNeedsLayout];
}



#define LABLE_Y_INSET (ISIPAD?15:8)
#define TIMELABEL_HEIGHT (ISIPAD?30:16)
#define MIN_HEIGHT (ISIPAD?130:73)
#define LABEL_WIDTH (ISIPAD?550:225)



- (CGSize)sizeForLabel:(UILabel *)label
{
    CGFloat width = CGRectGetWidth(label.bounds);
    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(width, 9999999) lineBreakMode:NSLineBreakByCharWrapping];
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        size.height += LABLE_Y_INSET;
    }
    return size;
}

- (void)layoutSubviews
{
    CGSize noticeSize = [self sizeForLabel:self.notice];
    CGSize messageSize = [self sizeForLabel:self.message];

    CGRect noticeFrame = self.notice.frame;
    noticeFrame.size = noticeSize;
    self.notice.frame = noticeFrame;
    
    CGRect messageFrame = self.message.frame;
    messageFrame.size = messageSize;
    messageFrame.origin.y = CGRectGetMaxY(noticeFrame);
    self.message.frame = messageFrame;
    
}


+ (CGFloat)getCellHeightByNotice:(PBGroupNotice *)groupNotice
{
    CGSize noticeSize = [groupNotice.desc sizeWithFont:CELL_NICK_FONT constrainedToSize:CGSizeMake(LABEL_WIDTH, 999999) lineBreakMode:NSLineBreakByCharWrapping];
    
    noticeSize.height += LABLE_Y_INSET;
    
    CGSize messageSize = [groupNotice.msg sizeWithFont:CELL_CONTENT_FONT constrainedToSize:CGSizeMake(LABEL_WIDTH, 999999) lineBreakMode:NSLineBreakByCharWrapping];
    if (messageSize.height != 0) {
        messageSize.height += LABLE_Y_INSET;
    }

    CGFloat height = noticeSize.height + messageSize.height;
    height += TIMELABEL_HEIGHT;
    return MAX(MIN_HEIGHT, height);
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
