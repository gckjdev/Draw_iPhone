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
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize content = _content;
@synthesize timestamp = _timestamp;
@synthesize image = _image;
@synthesize reply = _reply;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_avatar);
    PPRelease(_nickName);
    PPRelease(_content);
    PPRelease(_timestamp);
    PPRelease(_image);
    PPRelease(_reply);
    PPRelease(_action);
    [super dealloc];
}




//@synthesize delegate = _delegate;

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
    
    BBSPostActionCell *cell = ((BBSPostActionCell*)[topLevelObjects objectAtIndex:0]);
    cell.content.numberOfLines = CONTENT_TEXT_LINE;
    [cell.content setLineBreakMode:NSLineBreakByTruncatingTail];
    cell.content.font = CONTENT_FONT;
    cell.delegate = delegate;
    
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

+ (NSString *)contentTextForAction:(PBBBSAction *)action
{
    if (action.type == ActionTypeSupport) {
        return NSLS(@"kSupport");
    }
    NSString *text = action.content.text;
    if (action.source.hasActionId) {
        NSString *nick = [action.source actionNick];
        text = [NSString stringWithFormat:@"k回复%@: %@",nick,text];
    }
    return text;
}

+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action
{
    NSString *text = [BBSPostActionCell contentTextForAction:action];
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
    
    NSString *text = [BBSPostActionCell contentTextForAction:action];
    [self.content setText:text];
    
    //reset the size
    CGRect frame = self.content.frame;
    frame.size.height = [BBSPostActionCell heightForContentText:text];
    self.content.frame = frame;
        
    if (action.content.hasThumbImage) {
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:nil];
        self.image.hidden = YES;
    }else{
        self.image.hidden = YES;
    }
}

- (void)updateTimeStamp:(NSInteger)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    [self.timestamp setText:dateToChineseString(date)];
}


- (void)updateSupportContent
{
    [self.content setText:NSLS(@"kSupport")];
}

- (void)updateCellWithBBSAction:(PBBBSAction *)action
{
    self.action = action;
    [self updateUserInfo:action.createUser];
//    if (action.type == ActionTypeSupport) {
//        [self updateSupportContent];
//    }else{
    [self updateContentWithAction:action];
//    }

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
@end
