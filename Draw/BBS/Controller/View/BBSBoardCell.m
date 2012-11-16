//
//  BBSBoardCell.m
//  Draw
//
//  Created by gamy on 12-11-15.
//
//

#import "BBSBoardCell.h"
#import "UIImageView+WebCache.h"
#import "Bbs.pb.h"
#import "TimeUtils.h"
#import "BBSManager.h"

@implementation BBSBoardCell

@synthesize delegate = _delegate;
+ (BBSBoardCell *)createCell:(id)delegate
{
    NSString *identifier = [BBSBoardCell getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSBoardCell *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return  view;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSBoardCell";
}

+ (CGFloat)getCellHeight
{
    return 85.0f;
}

- (void)updateCellWithBoard:(PBBBSBoard *)board
{
    [self.icon setImageWithURL:[NSURL URLWithString:board.icon]];
    [self.name setText:board.name];
    self.statistic.text = [NSString stringWithFormat:@"%d / %d",board.topicCount, board.postCount];
    self.lastPost.text = [board.lastPost.content text];
    [self.author setText:board.lastPost.createUser.nickName];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:board.lastPost.createDate];
    self.timestamp.text = dateToChineseString(date);
    
    [BBSManager printBBSPost:board.lastPost];
}

- (void)dealloc {
    [_icon release];
    [_name release];
    [_statistic release];
    [_lastPost release];
    [_author release];
    [_timestamp release];
    [super dealloc];
}
@end
