//
//  ChatDetailCell.m
//  Draw
//
//  Created by haodong qiu on 12年6月19日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatDetailCell.h"
#import "LogUtil.h"
#import "PPMessage.h"
#import "UserManager.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "ShareImageManager.h"
#import "TimeUtils.h"
#import "LocaleUtils.h"
#import "PPMessage.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "GameApp.h"
#import "MyFriend.h"
#import "MessageStat.h"
#import "DrawHolderView.h"
#import "UIImageExt.h"
#import "UIImageView+Extend.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"

@interface ChatDetailCell()
{
    time_t _lastClickDown;
}
@property(nonatomic, assign)BOOL showTime;
@property(nonatomic, retain)PPMessage *message;
@property(nonatomic, retain)MessageStat *messageStat;
@property(nonatomic, assign)BOOL isReceive;

- (void)updateTextMessageView:(PPMessage *)message;
- (void)updateDrawMessageView:(PPMessage *)message;

@end



@implementation ChatDetailCell

#define VALUE(X) (ISIPAD?(2*X):(X))
#define TEXT_WIDTH_MAX    ((ISIPAD)?(470.0):(190.0))
#define TEXT_HEIGHT_MAX   MAXFLOAT

#define TEXT_EDGE_SPACE VALUE(ISIPAD?10:8)

#define TIME_FRAME (ISIPAD ? CGRectMake(34,14,700,40) : CGRectMake(10,6,300,17))

#define TEXT_FONT [UIFont systemFontOfSize:VALUE(14)]
#define LINE_BREAK_MODE NSLineBreakByWordWrapping

#define IMAGE_DEFAULT_SIZE (ISIPAD ? CGSizeMake(300,300) : CGSizeMake(120,120))
#define IMAGE_MAX_SIZE CGSizeMake(VALUE(160), VALUE(200))

#define HORIZONTAL_SPACE VALUE(10)

+ (NSString *)getCellIdentifier
{
    return @"ChatDetailCell";
}

+ (id)createCell:(id<ChatDetailCellDelegate>)delegate

{
    ChatDetailCell *cell = [ChatDetailCell createViewWithXibIdentifier:@"ChatDetailCell" ofViewIndex:ISIPAD];
    SET_VIEW_ROUND_CORNER(cell.holderView);
    cell.delegate = delegate;
    cell.isReceive = NO;
    [cell.msgLabel setFont:TEXT_FONT];
    [cell.msgLabel setLineBreakMode:LINE_BREAK_MODE];
    cell.holderView.backgroundColor = [UIColor clearColor];
    [cell.holderView addTarget:cell action:@selector(clickDown:) forControlEvents:UIControlEventTouchDown];
    [cell.holderView addTarget:cell action:@selector(clickUp:) forControlEvents:UIControlEventTouchUpInside];
    [cell.holderView addTarget:cell action:@selector(clickUp:) forControlEvents:UIControlEventTouchUpOutside];

    return cell;
}

- (void)clickDown:(id)sender
{
    _lastClickDown = time(0);
}
- (void)clickUp:(id)sender
{
    time_t minus = time(0) - _lastClickDown;
    
    if (minus >= 1) {
        //long click
        [self.delegate didLongClickMessage:self.message];
    }else{
        [self.delegate clickMessage:self.message];
    }
}

//- (void)clickMessage:(PPMessage *)message;
//
//- (void)didLongClickMessage:(PPMessage *)message;


#pragma mark - update the message show view.

- (void)updateHolderViewSize:(CGSize)size hasEdge:(BOOL)hasEdge
{
    if (hasEdge) {
        size.width += TEXT_EDGE_SPACE * 2;
        size.height += TEXT_EDGE_SPACE * 2;
    }
    [self.holderView updateWidth:size.width];
    [self.holderView updateHeight:size.height];
}

- (void)updateTextMessageView:(PPMessage *)message
{
    self.msgLabel.hidden = NO;
    [self.msgLabel setText:message.text];
    CGSize size = [ChatDetailCell contentSizeForMessage:message];
    [self updateHolderViewSize:size hasEdge:YES];
}


- (void)updateCellWithImage:(UIImage *)image
{
    [self.imgView setImage:image];
    CGSize size = [ChatDetailCell adjustImageSize:image.size];
    [self updateHolderViewSize:size hasEdge:NO];
    CGRect frame = CGRectFromCGSize(size);
    self.imgView.frame = frame;
}

+ (CGSize)sizeWithSize:(CGSize)size maxSize:(CGSize)maxSize
{
    CGFloat r = MAX(size.width/maxSize.width, size.width/maxSize.height);
    if (r <= 0) {
        return size;
    }
    return CGSizeMake(size.width/r, size.height/r);
}

+ (CGSize)adjustImageSize:(CGSize)size
{
    return [self sizeWithSize:size maxSize:IMAGE_MAX_SIZE];
}

+ (CGSize)contentSizeForMessage:(PPMessage *)message
{
    UIImage *image;
    if ([message isImageMessage]) {
        image = [message image];
        if (image) {
            return [self adjustImageSize:image.size];
        }
        return IMAGE_DEFAULT_SIZE;
    }else if([message isDrawMessage]){
        PPMessage *drawMessage = message;
        if (drawMessage.thumbImage == nil) {
            ShowDrawView *show = [ShowDrawView showViewWithFrame:CGRectFromCGSize(drawMessage.canvasSize) drawActionList:drawMessage.drawActionList delegate:nil];
            [show updateLayers:[DrawLayer defaultLayersWithFrame:CGRectFromCGSize(drawMessage.canvasSize)]];
            drawMessage.thumbImage = [show createImageWithSize:[ChatDetailCell adjustImageSize:drawMessage.canvasSize]];
        }
        image = [drawMessage thumbImage];
        if (image) {
            return [self adjustImageSize:image.size];
        }
        return IMAGE_DEFAULT_SIZE;
    }else{
        CGSize size = [message.text sizeWithFont:TEXT_FONT constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:LINE_BREAK_MODE];
        return size;
    }
}

- (void)updateDrawMessageView:(PPMessage *)message
{
    [self.imgView setHidden:NO];
    [self updateCellWithImage:message.thumbImage];
}

- (void)updateImageMessageView:(PPMessage *)message
{
    [self.imgView setHidden:NO];
    NSURL *url = nil;
    if ((message.status == MessageStatusFail || message.status == MessageStatusSending)&& message.imageUrl) {
        url = [NSURL fileURLWithPath:message.imageUrl];
    } else {
        url = [NSURL URLWithString:message.thumbImageUrl];
    }
    if (message.image && message.status != MessageStatusFail) {
        [self updateCellWithImage:message.image];
    }else{
        id<ChatDetailCellDelegate> cellDelegate = self.delegate;
        [cellDelegate retain];
        [message retain];
        [self.imgView setImageWithURL:url placeholderImage:[[ShareImageManager defaultManager] unloadBg] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (error == nil) {
                message.image = image;
                [self updateCellWithImage:message.image];
                [cellDelegate didMessage:message loadImage:image];
            }else{
                [self updateCellWithImage:[[ShareImageManager defaultManager] splitPhoto]];
            }
            
            [cellDelegate release];
            [message release];
        }];
    }
}

- (void)updateTime:(NSDate *)date
{
    NSString *dateString = dateToTimeLineString(date);    
    [self.timeButton setTitle:dateString forState:UIControlStateNormal];
}

- (void)updateSendingFlag
{
    MessageStatus status = self.message.status;
    [self.loadingView setHidden:YES];
    [self.failureView setHidden:YES];
    UIView *view = nil;
    if (status == MessageStatusFail) {
        view = self.failureView;
    }else if(status == MessageStatusSending){
        view = self.loadingView;
    }
    if (view) {
        [view setHidden:NO];
        CGFloat y = self.holderView.center.y;
        CGFloat x = CGRectGetMinX(self.holderView.frame) - HORIZONTAL_SPACE - CGRectGetWidth(view.bounds)/2;
        if (_isReceive) {
            x = CGRectGetMaxX(self.holderView.frame) + HORIZONTAL_SPACE + CGRectGetWidth(view.bounds)/2;
        }
        [view setCenter:CGPointMake(x, y)];
    }
}

- (void)dealloc {
    PPRelease(_message);
    PPRelease(_messageStat);
    PPRelease(_loadingView);
    PPRelease(_failureView);
    PPRelease(_avatarView);
    [_imgView release];
    [_msgLabel release];
    [_holderView release];
    [super dealloc];
}


+ (CGFloat)getCellHeight:(PPMessage *)message 
                showTime:(BOOL)showTime
{
    int space = CGRectGetMinY(TIME_FRAME);
    CGFloat height = space;
    if (showTime) {
        height += CGRectGetMaxY(TIME_FRAME);
    }
    CGSize contentSize = [self contentSizeForMessage:message];
    
    if (message.messageType == MessageTypeDraw || message.messageType == MessageTypeImage) {
        contentSize.height += 2 * TEXT_EDGE_SPACE;
        contentSize.width += 2 * TEXT_EDGE_SPACE;
    }
    height+=contentSize.height + space*3;
    return height;
}

- (void)updateAvatarImage:(MessageStat *)messageStat
{
    NSString *avatar = messageStat.isGroup ? self.message.fromUserToGroup.avatar : self.messageStat.friendAvatar;
    BOOL isMale = messageStat.isGroup ? self.message.fromUserToGroup.gender : self.messageStat.friendGender;
    
    if (!_isReceive) {
        avatar = [[UserManager defaultManager] avatarURL];
        isMale = [[[UserManager defaultManager] gender] isEqualToString:@"m"];
        self.avatarView.delegate = nil;
        self.avatarView.userId = nil;        
    }else{
        self.avatarView.delegate = self;
        
        if ([messageStat isGroup]){
            self.avatarView.userId = self.message.fromUserToGroup.userId;
        }
        else{
            self.avatarView.userId = [messageStat friendId];
        }
    }
    [self.avatarView setAvatarUrl:avatar gender:isMale];
}

- (void)didClickOnAvatar:(NSString*)userId
{
    if ([self.messageStat isGroup]){
        
        ViewUserDetail *detail = [ViewUserDetail viewUserDetailWithUserId:self.message.fromUserToGroup.userId
                                                                   avatar:self.message.fromUserToGroup.avatar
                                                                 nickName:self.message.fromUserToGroup.nickName];
        
        [UserDetailViewController presentUserDetail:detail inViewController:(id)[self theViewController]];
    }
    else{
        MessageStat *stat = self.messageStat;
        ViewUserDetail *detail = [ViewUserDetail viewUserDetailWithUserId:stat.friendId
                                                                   avatar:stat.friendAvatar
                                                                 nickName:stat.friendNickName];
        [UserDetailViewController presentUserDetail:detail inViewController:(id)[self theViewController]];
    }
}

- (void)updateViewsWithShowTime:(BOOL)showTime
{
    //update vertically
    self.timeButton.hidden = !showTime;
    CGFloat y = CGRectGetMinY(self.timeButton.frame);
    if (!self.showTime) {
        [self.avatarView updateOriginY:y];
        [self.holderView updateOriginY:y];
    }else{
        [self.avatarView updateOriginY:y+CGRectGetMaxY(self.timeButton.frame)];
        [self.holderView updateOriginY:y+CGRectGetMaxY(self.timeButton.frame)];
    }
    //update horizontally
    [self.avatarView updateOriginX:HORIZONTAL_SPACE];
    [self.holderView updateOriginX:CGRectGetMaxX(self.avatarView.frame) + HORIZONTAL_SPACE];
}

- (void)setCellWithMessageStat:(MessageStat *)messageStat
                       message:(PPMessage *)message 
                     indexPath:(NSIndexPath *)theIndexPath
                      showTime:(BOOL)showTime
{    
    self.messageStat = messageStat;
    self.message = message;
    self.showTime = showTime;
    self.indexPath = theIndexPath;
    self.isReceive = NO;
    
    if (message.isGroup){
        if ([[UserManager defaultManager] isMe:message.fromUserToGroup.userId]){
            self.isReceive = NO;
        }
        else{
            self.isReceive = YES;
        }
    }
    else{
       self.isReceive = ([message sourceType] == SourceTypeReceive);
    }
    
    [self updateViewsWithShowTime:showTime];
    [self updateAvatarImage:messageStat];
    [self updateTime:message.createDate];
    self.imgView.hidden = self.msgLabel.hidden = YES;
    if(message.messageType == MessageTypeDraw){
        [self updateDrawMessageView:message];
        [self.holderView setBackgroundImage:nil forState:UIControlStateNormal];
        [self.holderView setBackgroundImage:nil forState:UIControlStateHighlighted];
    } else if(message.messageType == MessageTypeImage){
        [self updateImageMessageView:message];
    }else{
        [self updateTextMessageView:message];
        self.imgView.hidden = YES;        
        if (!self.isReceive) {
            SET_BUTTON_ROUND_STYLE_ORANGE(self.holderView);
            [self.msgLabel setTextColor:COLOR_WHITE];
        }else{
            SET_BUTTON_ROUND_STYLE_YELLOW(self.holderView);
            [self.msgLabel setTextColor:COLOR_COFFEE];
        }
    }
    //如果是发送的消息就靠右
    if (!self.isReceive) {
        [self.holderView.superview reverseViewHorizontalContent];
    }

    [self updateSendingFlag];
}


#pragma mark action

@end
