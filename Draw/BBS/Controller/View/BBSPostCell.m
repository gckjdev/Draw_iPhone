//
//  BBSPostCell.m
//  Draw
//
//  Created by gamy on 12-11-19.
//
//

#import "BBSPostCell.h"
#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"

@implementation BBSPostCell
@synthesize post = _post;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostCell";
}

+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post
{
    return 184;
}

- (void)updateUserInfo:(PBBBSUser *)user
{
    [self.avatar setImageWithURL:[NSURL URLWithString:user.avatar]];
    if ([[UserManager defaultManager] isMe:user.userId]) {
        [self.nickName setText:NSLS(@"kMe")];
    }else{
        [self.nickName setText:user.nickName];
    }
}

- (void)updateContent:(PBBBSContent *)content
{
    
    [BBSManager printBBSContent:content];
    [self.content setText:content.text];
    NSURL *url = nil;
    if (content.type == ContentTypeImage) {
        url = [NSURL URLWithString:content.thumbImageUrl];
    }else if(content.type == ContentTypeDraw){
        url = [NSURL URLWithString:content.drawThumbUrl];
    }
    
//    PPDebug(@"<updateContent>,type = %d, URL = %@",content.type, url);
    
    if (url != nil) {
        [self.image setImageWithURL:url success:^(UIImage *image, BOOL cached) {
            //TODO scale the imageView
        } failure:^(NSError *error) {
            //TODO set defalt image.
        }];
    }
}

- (void)updateTimeStamp:(NSInteger)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    [self.timestamp setText:dateToChineseString(date)];
}

- (void)updateSupportCount:(NSInteger)supportCount
              commentCount:(NSInteger)commentCount
{
    [self.support setTitle:[NSString stringWithFormat:@"SP(%d)",supportCount]
                  forState:UIControlStateNormal];
    [self.comment setTitle:[NSString stringWithFormat:@"CM(%d)",commentCount]
                  forState:UIControlStateNormal];

}

- (void)updateReward:(PBBBSReward *)reward
{
    self.reward.hidden = NO;
    if (reward.hasWinner) {
        [self.reward setText:NSLS(@"kWIN")];
    }else if(reward.bonus > 0){
        [self.reward setText:[NSString stringWithFormat:@"$%d",reward.bonus]];
    }else{
        self.reward.hidden = YES;
    }
}

- (void)updateCellWithBBSPost:(PBBBSPost *)post
{
    self.post = post;
    [self updateUserInfo:post.createUser];
    [self updateContent:post.content];
    [self updateTimeStamp:post.createDate];
    [self updateSupportCount:post.supportCount commentCount:post.replyCount];
    [self updateReward:post.reward];
}



- (void)dealloc {
    [_avatar release];
    [_nickName release];
    [_content release];
    [_timestamp release];
    [_image release];
    [_support release];
    [_comment release];
    PPRelease(_post);
    [_reward release];
    [super dealloc];
}
- (IBAction)clickSupportButton:(id)sender {
}

- (IBAction)clickCommentButton:(id)sender {
}
@end
