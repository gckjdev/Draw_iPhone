//
//  BBSUserActionCell.m
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "BBSUserActionCell.h"
#import "StringUtil.h"
#import "ShowFeedController.h"

@interface BBSUserActionCell ()

@end

#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"

#define SPACE_CONTENT_TOP (ISIPAD ? 35 * 2.33 : 35)
#define SPACE_CONTENT_IMAGE (ISIPAD ? 10 * 2.33 : 10)
#define SPACE_IMAGE_SOURCE (ISIPAD ? 15 * 2.33 : 15)
#define SPACE_SOURCE_BOTTOM (ISIPAD ? 20 * 2.33 : 20)

#define SPACE_TEXT_SOURCE_IMAGE (ISIPAD ? 100 * 2.33 : 100)
#define SPACE_TEXT_SOURCE_NO_IMAGE (ISIPAD ? 10 * 2.33 : 10)

#define SPACE_SPLITLINE_SOURCE (ISIPAD ? 5 * 2.33 : 5)

//#define IMAGE_HEIGHT (ISIPAD ? 80 * 2.33 : 80)

#define CONTENT_WIDTH (ISIPAD ? 206 * 2.33 : 206)
#define SOURCE_WIDTH (ISIPAD ? 206 * 2.33 : 206)

#define SOURCE_MAX_HEIGHT (ISIPAD ? 40 * 2.33 : 40)

#define Y_CONTENT_TEXT (ISIPAD ? 5 * 2.33 : 5)
#define Y_SOURCE_TEXT (ISIPAD ? 5 * 2.33 : 5)

#define CONTENT_MAX_HEIGHT 99999999

#define CONTENT_FONT [[BBSFontManager defaultManager] myActionContentFont]
#define SOURCE_FONT [[BBSFontManager defaultManager] actionSourceFont]

#define SPACE_TOP_SOURCE_SUPPORT (ISIPAD ? 60 * 2.33 : 60)

@implementation BBSUserActionCell
@synthesize source = _source;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_source);
    PPRelease(_action);
    [_splitLine release];
    [_supportImage release];
    [super dealloc];
}




//@synthesize delegate = _delegate;

- (void)initViews
{
    self.content.numberOfLines = INT_MAX;
    self.content.font = CONTENT_FONT;
    
    self.nickName.font = [_bbsFontManager myActionNickFont];
    self.timestamp.font = [_bbsFontManager myActionDateFont];

    
    [self.content setLineBreakMode:NSLineBreakByCharWrapping];

    self.source.numberOfLines = INT_MAX;
    [self.source setLineBreakMode:NSLineBreakByTruncatingTail];
    self.source.font = SOURCE_FONT;
    [self.source setTextColor:[[BBSColorManager defaultManager]
                               userActionSourceColor]]
    ;
    [self.splitLine setBackgroundColor:[[BBSColorManager defaultManager] userActionSplitColor]];
    [self.supportImage setImage:[[BBSImageManager defaultManager] bbsPostSupportImage]];
}

+ (id)createCell:(id)delegate
{
    BBSUserActionCell *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    
    [cell initViews];
    [cell setUseContentLabel:YES];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSUserActionCell";
}


+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithMyFont:CONTENT_FONT
                   constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT)
                       lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}

+ (CGFloat)heightForSourceText:(NSString *)text
{
    CGSize size = [text sizeWithMyFont:SOURCE_FONT
                   constrainedToSize:CGSizeMake(SOURCE_WIDTH, SOURCE_MAX_HEIGHT)
                       lineBreakMode:NSLineBreakByTruncatingTail];
    size.height += 2*Y_SOURCE_TEXT;
    return size.height;
}


+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action
{
    CGFloat sourceHeight = [BBSUserActionCell heightForSourceText:action.showSourceText];
    if ([action isSupport]) {
        return sourceHeight + SPACE_TOP_SOURCE_SUPPORT + SPACE_SOURCE_BOTTOM;
    }

    CGFloat contentHeight = [BBSUserActionCell heightForContentText:action.contentText];
    CGFloat height = contentHeight + sourceHeight;
    if (action.content.hasThumbImage) {
        height += (SPACE_CONTENT_TOP + SPACE_TEXT_SOURCE_IMAGE) + SPACE_SOURCE_BOTTOM;
    }else{
        height += (SPACE_CONTENT_TOP + SPACE_TEXT_SOURCE_NO_IMAGE + SPACE_SOURCE_BOTTOM);
    }
    return height;
}

- (void)updateUserInfo:(PBBBSUser *)user
{
    [self.nickName setText:user.showNick];
    [self.avatar setImageWithURL:user.avatarURL placeholderImage:user.defaultAvatar];
    [self showVipFlag:user.isVIP];
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
    [self.source setText:action.showSourceText];
    if ([action isSupport]) {
        self.supportImage.hidden = NO;
        self.content.hidden = YES;
        self.image.hidden = YES;
        
        CGFloat y = SPACE_TOP_SOURCE_SUPPORT;
        CGFloat height = [BBSUserActionCell heightForSourceText:action.showSourceText];
        [self resetView:self.source y:y height:height];
        [self resetView:self.splitLine
                      y:(y - SPACE_SPLITLINE_SOURCE)
                 height:1];
        return;
    }else{
        self.supportImage.hidden = YES;
        self.content.hidden = NO;
    }
    
    [self.content setText:action.contentText];
    
    //reset the content size
    CGFloat height = [BBSUserActionCell heightForContentText:action.contentText];
    [self resetView:self.content y:CGRectGetMinY(self.content.frame) height:height];

    CGFloat y = 0;

    //set image frame
    if (action.content.hasThumbImage) {
//        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:PLACEHOLDER_IMAGE success:^(UIImage *image, BOOL cached) {
//            [self updateImageViewFrameWithImage:image];
//        } failure:^(NSError *error) {
//            
//        }];
        
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:PLACEHOLDER_IMAGE completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (error == nil) {
                [self updateImageViewFrameWithImage:image];
            }
        }];
        
        //reset image frame center
        self.image.hidden = NO;

        y = CGRectGetMaxY(self.content.frame) + SPACE_CONTENT_IMAGE;
        CGFloat width = IMAGE_HEIGHT;
        CGFloat height = IMAGE_HEIGHT;
        CGFloat x =  CGRectGetMinX(self.image.frame);
        self.image.frame = CGRectMake(x, y, width, height);

        //set source frame
        y = CGRectGetMaxY(self.image.frame) + SPACE_IMAGE_SOURCE;
        height = [BBSUserActionCell heightForSourceText:action.showSourceText];
        [self resetView:self.source y:y height:height];
    }else{
        self.image.hidden = YES;
        
        //set source frame
        y = CGRectGetMaxY(self.content.frame) + SPACE_TEXT_SOURCE_NO_IMAGE;
        height = [BBSUserActionCell heightForSourceText:action.showSourceText];
        [self resetView:self.source y:y height:height];
    }
    
    [self resetView:self.splitLine y:(y-SPACE_SPLITLINE_SOURCE) height:1];
}


- (void)updateCellWithBBSAction:(PBBBSAction *)action
{
    self.action = action;
    [self updateUserInfo:action.createUser];
    [self updateContentWithAction:action];
    [[self timestamp] setText:action.createDateString];
}
- (void)setCellInfo:(PBBBSAction *)action
{
    [self updateCellWithBBSAction:action];
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
    }
    else if(self.action.content.type == ContentTypeImage && delegate &&
             [delegate respondsToSelector:@selector(didClickImageWithURL:)])
    {
        [delegate didClickImageWithURL:self.action.content.largeImageURL];
    }
    else if([self.action.content.opusId length] > 0){
        // TODO BBS OPUS go to opus feed detail
        [ShowFeedController enterWithFeedId:self.action.content.opusId fromController:delegate];
    }
}


@end
