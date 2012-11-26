//
//  BBSUserActionCell.m
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "BBSUserActionCell.h"

@interface BBSUserActionCell ()

@end

#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"

#define SPACE_CONTENT_TOP 35
#define SPACE_CONTENT_IMAGE 10
#define SPACE_IMAGE_SOURCE 10
#define SPACE_SOURCE_BOTTOM 10

#define SPACE_TEXT_SOURCE_IMAGE 100
#define SPACE_TEXT_SOURCE_NO_IMAGE 10


#define IMAGE_HEIGHT 80

#define CONTENT_WIDTH 240
#define SOURCE_WIDTH 240
#define CONTENT_MAX_HEIGHT 99999999
#define SOURCE_MAX_HEIGHT 99999999

#define Y_CONTENT_TEXT 5
#define Y_SOURCE_TEXT 5

#define CONTENT_FONT [UIFont systemFontOfSize:15]
#define SOURCE_FONT [UIFont systemFontOfSize:13]



@implementation BBSUserActionCell
@synthesize source = _source;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_source);
    PPRelease(_action);
    [super dealloc];
}




//@synthesize delegate = _delegate;

+ (id)createCell:(id)delegate
{
    BBSUserActionCell *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    
    cell.content.numberOfLines = 0;
    [cell.content setLineBreakMode:NSLineBreakByTruncatingTail];
    cell.content.font = CONTENT_FONT;
    
    cell.source.numberOfLines = 0;
    [cell.source setLineBreakMode:NSLineBreakByTruncatingTail];
    cell.source.font = SOURCE_FONT;
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSUserActionCell";
}


+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT
                   constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT)
                       lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}

+ (CGFloat)heightForSourceText:(NSString *)text
{
    CGSize size = [text sizeWithFont:SOURCE_FONT
                   constrainedToSize:CGSizeMake(SOURCE_WIDTH, SOURCE_MAX_HEIGHT)
                       lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_SOURCE_TEXT;
    return size.height;
}


+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action
{
    CGFloat contentHeight = [BBSUserActionCell heightForContentText:action.contentText];
    CGFloat sourceHeight = [BBSUserActionCell heightForSourceText:action.showSourceText];
    CGFloat height = contentHeight + sourceHeight;
    if (action.content.hasThumbImage) {
        height += (SPACE_CONTENT_TOP + SPACE_TEXT_SOURCE_IMAGE) + SPACE_SOURCE_BOTTOM;
    }else{
        height += (SPACE_CONTENT_TOP + SPACE_TEXT_SOURCE_NO_IMAGE + SPACE_SOURCE_BOTTOM);
    }
    PPDebug(@"\n<getCellHeightWithBBSAction>,height = %f.\n",height);
    return height;
}

- (void)updateUserInfo:(PBBBSUser *)user
{
    [self.nickName setText:user.showNick];
    [self.avatar setImageWithURL:user.avatarURL placeholderImage:user.defaultAvatar];
}

- (void)resetView:(UIView *)view y:(CGFloat)y height:(CGFloat)height
{
    CGRect frame = view.frame;
    frame.size.height = height;
    frame.origin.y = y;
    view.frame = frame;
}

- (void)updateContentWithAction:(PBBBSAction *)action
{
    [self.content setText:action.contentText];
    [self.source setText:action.showSourceText];
    //reset the content size
    CGFloat height = [BBSUserActionCell heightForContentText:action.contentText];
    [self resetView:self.content y:CGRectGetMinY(self.content.frame) height:height];



    //set image frame
    if (action.content.hasThumbImage) {
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:nil];
        //reset image frame center
        self.image.hidden = NO;

        CGFloat y = CGRectGetMaxY(self.content.frame) + SPACE_CONTENT_IMAGE;
        CGFloat width = IMAGE_HEIGHT;
        CGFloat height = IMAGE_HEIGHT;
        CGFloat x =  (self.bounds.size.width - width) / 2;
        self.image.frame = CGRectMake(x, y, width, height);

        //set source frame
        y = CGRectGetMaxY(self.image.frame) + SPACE_IMAGE_SOURCE;
        height = [BBSUserActionCell heightForSourceText:action.showSourceText];
        [self resetView:self.source y:y height:height];
    }else{
        self.image.hidden = YES;
        
        //set source frame
        CGFloat y = CGRectGetMaxY(self.content.frame) + SPACE_TEXT_SOURCE_NO_IMAGE;
        height = [BBSUserActionCell heightForSourceText:action.showSourceText];
        [self resetView:self.source y:y height:height];
    }
    
    PPDebug(@"\n====<print>====\ncontent frame = %@,\nimage frame = %@,\nsource frame = %@,\n</print>",NSStringFromCGRect(self.content.frame),NSStringFromCGRect(self.image.frame),NSStringFromCGRect(self.source.frame));
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

@end
