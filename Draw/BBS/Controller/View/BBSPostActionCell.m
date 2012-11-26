//
//  BBSPostActionCell.m
//  Draw
//
//  Created by gamy on 12-11-21.
//
//

#import "BBSPostActionCell.h"
#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"

#define SPACE_CONTENT_TOP 35
#define SPACE_CONTENT_BOTTOM_IMAGE 100 //IMAGE TYPE OR DRAW TYPE
#define SPACE_CONTENT_BOTTOM_TEXT 40 //TEXT TYPE
#define IMAGE_HEIGHT 80
#define CONTENT_TEXT_LINE 1000

#define CONTENT_WIDTH 205
#define CONTENT_MAX_HEIGHT 10000

#define Y_CONTENT_TEXT 5
#define CONTENT_FONT [UIFont systemFontOfSize:15]


@implementation BBSPostActionCell
@synthesize reply = _reply;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_reply);
    PPRelease(_action);
    [super dealloc];
}


+ (id)createCell:(id)delegate
{    
    BBSPostActionCell  *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    cell.content.numberOfLines = CONTENT_TEXT_LINE;
    [cell.content setLineBreakMode:NSLineBreakByTruncatingTail];
    cell.content.font = CONTENT_FONT;
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostActionCell";
}


+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}


+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action
{
    NSString *text = action.showText;
    CGFloat height = [BBSPostActionCell heightForContentText:text];

    if (action.content.hasThumbImage) {
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_IMAGE);
    }else{
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_TEXT);
    }
    return height;
}

- (void)updateUserInfo:(PBBBSUser *)user
{
    [self.nickName setText:user.showNick];
    [self.avatar setImageWithURL:user.avatarURL placeholderImage:user.defaultAvatar];
}

- (void)updateContentWithAction:(PBBBSAction *)action
{
    NSString *text = [action showText];
    [self.content setText:text];
    
    //reset the size
    CGRect frame = self.content.frame;
    frame.size.height = [BBSPostActionCell heightForContentText:text];
    self.content.frame = frame;
        
    if (action.content.hasThumbImage) {
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:nil];
        self.image.hidden = NO;
    }else{
        self.image.hidden = YES;
    }
}

- (void)updateTimeStamp:(NSInteger)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    [self.timestamp setText:dateToChineseString(date)];
}


- (void)updateCellWithBBSAction:(PBBBSAction *)action
{
    self.action = action;
    [self updateUserInfo:action.createUser];
    [self updateContentWithAction:action];
    [self updateTimeStamp:action.createDate];
}


- (IBAction)clickRepyButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didClickReplyButtonWithAction:)]) {
        [delegate didClickReplyButtonWithAction:self.action];
    }
}

- (IBAction)clickPayButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didClickPayButtonWithAction:)]) {
        [delegate didClickPayButtonWithAction:self.action];
    }
}



#pragma mark - action delegate
- (void)clickAvatarButton:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didClickUserAvatar:)]) {
        [delegate didClickUserAvatar:self.action.createUser];
    }
}
- (void)clickImageButton:(id)sender
{
    //show draw...
    if (self.action.content.type == ContentTypeDraw && delegate
        && [delegate respondsToSelector:@selector(didClickDrawImageWithAction:)]) {
        [delegate didClickDrawImageWithAction:self.action];

    //show image...
    }else if(self.action.content.type == ContentTypeImage && delegate &&
             [delegate respondsToSelector:@selector(didClickImageWithURL:)])
    {
        [delegate didClickImageWithURL:self.action.content.largeImageURL];
    }
}

@end
