//
//  CommonActionCell.m
//  Draw
//
//  Created by 王 小涛 on 13-7-1.
//
//

#import "CommonActionCell.h"
#import "PBOpusAction+Extend.h"

#define AVATAR_VIEW_FRAME [DeviceDetection isIPAD] ? CGRectMake(12, 10, 74, 77) : CGRectMake(5, 9, 31, 32)
#define NICK_FONT_SIZE ([DeviceDetection isIPAD] ? 11*2 : 12)
#define COMMENT_ITEM_HEIGHT ([DeviceDetection isIPAD] ? 110 : 60)
#define CONTENT_FONT ([DeviceDetection isIPAD] ? 23 : 12)
#define CONTENT_WIDTH ([DeviceDetection isIPAD] ? 500 : 204)
#define CONTENT_CONST_HEIGHT ([DeviceDetection isIPAD] ? 78 : 40)

@interface CommonActionCell()

@property (retain, nonatomic) PBOpusAction *action;
@property (retain, nonatomic) AvatarView *avatarView;

@end

@implementation CommonActionCell

- (void)dealloc {
    [_action release];
    [_avatarView release];
    [_nickNameLabel release];
    [_contentLabel release];
    [_timeLabel release];
    [_flowerImageView release];
    [super dealloc];
}


+ (CGFloat)getCellHeight:(PBOpusAction *)action{
    
    if (action.actionType == PBOpusActionTypeOpusActionTypeFlower) {
        return COMMENT_ITEM_HEIGHT;
    }
    
    NSString *str = [action actionString];
    CGSize size = [str sizeWithFont:CONTENT_FONT constrainedToSize:CGSizeMake(CONTENT_WIDTH, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    CGFloat height = CONTENT_CONST_HEIGHT + size.height;
    
    return height;
}



- (void)setCellInfo:(PBOpusAction *)action{

    //set avatar
    self.action = action;
    
    PBGameUser *author = action.userInfo;
    
    [_avatarView removeFromSuperview];
    _avatarView = [[AvatarView alloc] initWithUrlString:author.avatar
                                                  frame:AVATAR_VIEW_FRAME
                                                 gender:author.gender
                                                  level:0];
    _avatarView.delegate = self;
    _avatarView.userId = author.userId;
    [self addSubview:_avatarView];
    [_avatarView release];
    
    //set times
    [_timeLabel setText:[_action createTimeString]];
    
    // set user name
    [_nickNameLabel setText:author.nickName];
    
    // set action string
    if ([DeviceDetection isOS6]) {
        [_contentLabel setAttributedText:[action actionAttributedStringWithFont:_contentLabel.font]];
    }else{
        [_contentLabel setText:[_action actionString]];
    }
    
    if (action.actionType == PBOpusActionTypeOpusActionTypeFlower) {
        _flowerImageView.hidden = NO;
    }else{
        _flowerImageView.hidden = YES;
    }
}


- (IBAction)clickActionButton:(id)sender {
    
    if ([delegate respondsToSelector:@selector(didClickOnCommentButton:)]) {
        [delegate didClickOnCommentButton:_action];
    }
}


#pragma mark - avatar view delegate
- (void)didClickOnAvatar:(NSString *)userId
{
    if ([delegate respondsToSelector:@selector(didClickOnUser:)]) {
        [delegate didClickOnUser:_action.userInfo];
    }
}


@end
