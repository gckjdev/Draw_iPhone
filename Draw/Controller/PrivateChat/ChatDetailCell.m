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
//#import "DrawUserInfoView.h"
#import "DiceUserInfoView.h"
#import "GameApp.h"
#import "MyFriend.h"
#import "MessageStat.h"
#import "CommonUserInfoView.h"
#import "DrawHolderView.h"
#import "UIImageExt.h"

CGRect CGRectFrom(CGPoint origin, CGSize size){
    return CGRectMake(origin.x, origin.y, size.width, size.height); 
}

@interface ChatDetailCell()
{
    BOOL _showTime;
    PPMessage *_message;
    MessageStat *_messageStat;
    BOOL _isReceive;
}
//- (IBAction)clickEnlargeButton:(id)sender;
//- (IBAction)clcikAvatarButton:(id)sender;

@property(nonatomic, assign)BOOL showTime;
@property(nonatomic, retain)PPMessage *message;
@property(nonatomic, retain)MessageStat *messageStat;
@property(nonatomic, assign)BOOL isReceive;

- (CGRect)reverseByRect:(CGRect)rect;
//- (void)translateX:(CGFloat)x y:(CGFloat)y views:(NSArray *)views;
- (void)updateTextMessageView:(TextMessage *)message;
- (void)updateDrawMessageView:(DrawMessage *)message;

+ (CGFloat)contentStartY:(BOOL)hasTime; //计算图或者文字的起始y坐标


@end

@implementation ChatDetailCell
@synthesize timeButton;
@synthesize avatarButton;
@synthesize contentButton;
@synthesize showDrawView;
@synthesize message = _message;
@synthesize messageStat = _messageStat;
@synthesize showTime = _showTime;
@synthesize isReceive = _isReceive;
//@synthesize superController = _superController;
@synthesize loadingView;
@synthesize failureView;
#pragma mark adjust frame


#define TEXT_WIDTH_MAX    (([DeviceDetection isIPAD])?(473.0):(198.0))
#define TEXT_HEIGHT_MAX   (([DeviceDetection isIPAD])?(2000.0):(1000.0))
#define TEXT_VERTICAL_EDGE (([DeviceDetection isIPAD])?(22.0):(15.0)) //文字和泡泡的y上的距离

#define TIME_HEIGHT  (([DeviceDetection isIPAD])?(34):(17))//时间的高度

#define SPACE_TOP_TIME (([DeviceDetection isIPAD])?(11.0):(5.0)) //时间和顶端之间的间隔
#define SPACE_CONTENT_BOTTOM (([DeviceDetection isIPAD])?(25.0):(15.0)) //内容和底部之间的间隔
#define SPACE_TIME_CONTENT (([DeviceDetection isIPAD])?(11.0):(5.0)) //时间和内容之间的间隔
#define SPACE_AVATAR_CONTENT (([DeviceDetection isIPAD])?(10.0):(5.0)) //头像和内容之间的间隔

#define SPACE_CONTENT_FLAG (([DeviceDetection isIPAD])?(10.0):(5.0)) //时间和顶端之间的间隔

#define TEXT_FONT_SIZE  (([DeviceDetection isIPAD])?(30):(14))

//#define DRAW_VIEW_SIZE (([DeviceDetection isIPAD])?CGSizeMake(180,180):CGSizeMake(80,80))


#define MESSAGE_MAX_SIZE (([DeviceDetection isIPAD])?CGSizeMake(200,360):CGSizeMake(100,160))


#define BUBBLE_TIP_WIDTH   (([DeviceDetection isIPAD])?(20):(12)) //尖尖的部分距离文字的距离
#define BUBBLE_NOT_TIP_WIDTH    (([DeviceDetection isIPAD])?(20):(11))//不尖部分和文字的距离



//保持view的大小和x不变，单单改变y值
- (void)setViews:(NSArray *)views yOrigin:(CGFloat)y
{
    for (UIView *view in views) {
        CGPoint origin = view.frame.origin;
        origin.y = y;
        view.frame = CGRectFrom(origin, view.frame.size);

    }
}

//使得view的中心点x坐标与x对齐
- (void)setView:(UIView *)view centerX:(CGFloat)x
{
    view.center = CGPointMake(x, view.center.y);
}

//使得view的中心点y坐标与y对齐
- (void)setView:(UIView *)view centerY:(CGFloat)y
{
    view.center = CGPointMake(view.center.x, y);    
}

//保持view的origin不变，调整size
- (void)updateView:(UIView *)view origin:(CGPoint)origin 
{
    view.frame = CGRectFrom(origin, view.frame.size);
}

//保持view的origin不变，调整size
- (void)updateView:(UIView *)view size:(CGSize)size 
{
    view.frame = CGRectFrom(view.frame.origin, size);
}

//将frame左右翻转
- (CGRect)reverseByRect:(CGRect)rect
{
    CGRect newRect = CGRectMake(self.frame.size.width-rect.origin.x-rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
    return newRect;
}

+ (CGFloat)contentStartY:(BOOL)hasTime //计算图或者文字的起始y坐标
{
    if (!hasTime) {
        return SPACE_TOP_TIME;
    }
    return SPACE_TOP_TIME + TIME_HEIGHT + SPACE_TIME_CONTENT;
}


+ (CGSize)adjustContentSize:(CGSize)size
{
    CGSize maxSize = MESSAGE_MAX_SIZE;
    if (size.width <= maxSize.width && size.height <= maxSize.height) {
        return size;
    }
    CGFloat r = MAX(size.width / maxSize.width, size.height / maxSize.height);
    
    return CGSizeMake(size.width / r, size.height / r);
    
}

+ (CGSize)sizeForMessageView:(NSString *)text
{
    UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
    CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
    textSize.height += TEXT_VERTICAL_EDGE * 2;
    textSize.width += BUBBLE_TIP_WIDTH + BUBBLE_NOT_TIP_WIDTH;
    return textSize;
}

//使得view以右上角为基点，不变
- (void)updateView:(UIView *)view rightTop:(CGPoint)rightTopPoint
{
    CGSize size = view.frame.size;
    CGPoint origin = CGPointMake(rightTopPoint.x - size.width, rightTopPoint.y) ;
    view.frame = CGRectFrom(origin, size);
}


#pragma mark - update the message show view.
- (void)updateTextMessageView:(TextMessage *)message
{
    [self.showDrawView setHidden:YES];
    [self.contentButton setTitle:message.text forState:UIControlStateNormal];
    CGSize size = [ChatDetailCell sizeForMessageView:message.text];
    [self updateView:self.contentButton size:size];
}


- (void)updateContentButtonFrame:(CGSize)contentSize
{
    [self.contentButton setTitle:nil forState:UIControlStateNormal];
    
    CGSize size = [ChatDetailCell adjustContentSize:contentSize];
    
    CGFloat width = size.width + BUBBLE_TIP_WIDTH + BUBBLE_NOT_TIP_WIDTH;
    CGFloat height = (size.height + TEXT_VERTICAL_EDGE * 2);
    [self updateView:self.contentButton size:CGSizeMake(width, height)];    
}
- (CGRect)showViewFrame:(CGSize)size
{
//    CGPoint contentOrigin = self.contentButton.frame.origin;
    CGPoint origin = CGPointMake(CGRectGetMinX(self.contentButton.frame) + BUBBLE_TIP_WIDTH, CGRectGetMinY(self.contentButton.frame) + TEXT_VERTICAL_EDGE);
    CGRect rect = CGRectZero;
    rect.origin = origin;
    rect.size = [ChatDetailCell adjustContentSize:size];
    return rect;
//    [self updateView:self.showDrawView origin:origin];
}

- (void)updateDrawMessageView:(DrawMessage *)message
{
    //create the image once...
//    [self.showDrawView removeFromSuperview];

    [self updateContentButtonFrame:message.canvasSize];
    
    CGSize size = [ChatDetailCell adjustContentSize:message.canvasSize];
    
    if (self.showDrawView == nil) {
        if (message.thumbImage) {
            CGRect frame = CGRectFromCGSize(size);
            self.showDrawView = [ShowDrawView showViewWithFrame:frame drawActionList:nil delegate:self];
        }else{
            CGRect frame = CGRectFromCGSize(message.canvasSize);
            self.showDrawView = [ShowDrawView showViewWithFrame:frame drawActionList:message.drawActionList delegate:self];
        }
        
        [self.showDrawView setPressEnable:YES];
        
        DrawHolderView *holder = [DrawHolderView drawHolderViewWithFrame:[self showViewFrame:message.canvasSize] contentView:self.showDrawView];
        [self addSubview:holder];
    }
    if (!message.thumbImage) {
        [self.showDrawView show];
        
        message.thumbImage = [self.showDrawView createImageWithSize:size];
    }
    [self.showDrawView showImage:message.thumbImage];
}

- (void)updateImageMessageView:(ImageMessage *)message
{
    [self updateContentButtonFrame:message.thumbImageSize];
    
    NSURL *url = nil;
    if ((message.status == MessageStatusFail || message.status == MessageStatusSending)&& message.imageUrl) {
        url = [NSURL fileURLWithPath:message.imageUrl];
    } else {
        url = [NSURL URLWithString:message.thumbImageUrl];
    }
    if (message.image && message.status != MessageStatusFail) {
        [self.contentButton setImage:message.image forState:UIControlStateNormal];
    }else{
        
        [[SDWebImageManager sharedManager] downloadWithURL:url delegate:self options:SDWebImageRetryFailed success:^(UIImage *image, BOOL cached) {
            if (!message.hasCalSize && self.delegate && [self.delegate respondsToSelector:@selector(didMessage:loadImage:)])
            {
                message.thumbImageSize = image.size;
                message.hasCalSize = YES;
//                [self.delegate didMessage:message loadImage:image];
            }
            [self.contentButton setImage:image forState:UIControlStateNormal];            

        } failure:^(NSError *error) {
            [self.contentButton setImage:[[ShareImageManager defaultManager] splitPhoto] forState:UIControlStateNormal];

        }];
        
//        [self.contentButton setImageWithURL:url
//                           placeholderImage:[[ShareImageManager defaultManager] placeholderPhoto]
//                                    success:^(UIImage *image, BOOL cached) {
//                                        
//                                        
//                                    }
//                                    failure:^(NSError *error) {
//                                    }];
    }
}

- (void)didClickShowDrawView:(ShowDrawView *)showDrawView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickMessage:withDrawActionList:)]) {
        [self.delegate clickMessage:self.message
                 withDrawActionList:[(DrawMessage *)self.message drawActionList]];
    }
}

- (void)didLongClickShowDrawView:(ShowDrawView *)showDrawView
{
    [self longPressContentButton:self.contentButton];
}
- (void)updateTime:(NSDate *)date
{
    NSString *dateString = dateToTimeLineString(date);
    
    [self.timeButton setTitle:dateString forState:UIControlStateNormal];
    CGSize textSize = [dateString sizeWithFont:self.timeButton.titleLabel.font
                             constrainedToSize:CGSizeMake(3000, TIME_HEIGHT)
                                 lineBreakMode:UILineBreakModeCharacterWrap];
    textSize.height = TIME_HEIGHT;
    textSize.width += 10;
    [self updateView:self.timeButton size:textSize];
    [self setView:self.timeButton centerX:self.center.x];
}

- (void)updateSendingFlag:(MessageStatus)status
{
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
        CGFloat y = self.contentButton.center.y;
        CGFloat x = self.contentButton.frame.origin.x - SPACE_CONTENT_FLAG - view.frame.size.width / 2;
        [view setCenter:CGPointMake(x, y)];
    }
}

- (void)dealloc {

    [self.showDrawView stop];
    PPRelease(_message);
    PPRelease(_messageStat);
    PPRelease(timeButton);
    PPRelease(avatarButton);
    PPRelease(contentButton);
    PPRelease(showDrawView);
//    PPRelease(_superController);
    PPRelease(loadingView);
    PPRelease(failureView);
    PPRelease(_avatarView);
    [super dealloc];
}

+ (id)createCell:(id<ChatDetailCellDelegate>)delegate isReceive:(BOOL)isRecevie

{
    NSString* cellId = [self getCellIdentifierIsReceive:isRecevie];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ChatDetailCell *cell = (ChatDetailCell*)[topLevelObjects objectAtIndex:0];
    cell.delegate = delegate;
    cell.isReceive = isRecevie;
    [cell.contentButton.titleLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    UIEdgeInsets sets;
    if (isRecevie) {
        [cell.contentButton setBackgroundImage:[[ShareImageManager defaultManager] leftBubbleImage] forState:UIControlStateNormal];
        sets = UIEdgeInsetsMake(TEXT_VERTICAL_EDGE, BUBBLE_TIP_WIDTH, TEXT_VERTICAL_EDGE, BUBBLE_NOT_TIP_WIDTH);
        [cell.contentButton setTitleColor:[UIColor colorWithRed:15/255.0 green:91/255.0 blue:13/255.0 alpha:1] forState:UIControlStateNormal];
    }else{
        [cell.contentButton setBackgroundImage:[[ShareImageManager defaultManager] rightBubbleImage] forState:UIControlStateNormal];
        sets = UIEdgeInsetsMake(TEXT_VERTICAL_EDGE, BUBBLE_NOT_TIP_WIDTH, TEXT_VERTICAL_EDGE, BUBBLE_TIP_WIDTH);
        [cell.contentButton setTitleColor:[UIColor colorWithRed:14/255.0 green:17/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
    }
    [cell.contentButton setImageEdgeInsets:sets];
    [cell.contentButton setTitleEdgeInsets:sets];
    
    [cell.timeButton setTitleColor:[UIColor colorWithRed:194/255. green:144/255. blue:105/255. alpha:1] forState:UIControlStateNormal];
    cell.avatarView.userInteractionEnabled = NO;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:cell action:@selector(longPressContentButton:)];
    longPress.minimumPressDuration = 0.8; //定义按的时间
    [cell.contentButton addGestureRecognizer:longPress];
    [longPress release];
    
    
    [cell.contentButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    return cell;
}

+ (NSString*)getCellIdentifierIsReceive:(BOOL)isRecevie
{
    return isRecevie ? @"ChatDetailCellReceive" : @"ChatDetailCellSend";
}


+ (CGFloat)getCellHeight:(PPMessage *)message 
                showTime:(BOOL)showTime
{
    CGFloat height = [ChatDetailCell contentStartY:showTime];

    //PPDebug(@"<getCellHeight> text = %@, type = %d", message.text,message.messageType);
    
    
    // PPDebug(@"height1 = %f", height);

    switch (message.messageType) {
            
        case MessageTypeDraw:
        {
            CGSize size = [ChatDetailCell adjustContentSize:[(DrawMessage *)message canvasSize]];
            height += (size.height + TEXT_VERTICAL_EDGE * 2);
            break;
        }
        case MessageTypeImage:
        {
            CGSize size = [ChatDetailCell adjustContentSize:[(ImageMessage *)message thumbImageSize]];
            height += (size.height + TEXT_VERTICAL_EDGE * 2);
            PPDebug(@"image height = %f, message id = %@", height,message.messageId);
            break;
        }
        case MessageTypeText:
        case MessageTypeLocationRequest:
        case MessageTypeLocationResponse:            
        default:
        {
            CGSize size = [ChatDetailCell sizeForMessageView:message.text];
            height += size.height;
            //PPDebug(@"height2.2 = %f", height);
            break;
        }
    }
    height += SPACE_CONTENT_BOTTOM;
//    PPDebug(@"total height = %f", height);
    return height;
}

- (void)updateAvatarImage:(MessageStat *)messageStat
{
    self.avatarView.frame = self.avatarButton.frame;
    NSString *avatar = self.messageStat.friendAvatar;
    BOOL isMale = self.messageStat.friendGender;
    
    if (!_isReceive) {
        avatar = [[UserManager defaultManager] avatarURL];
        isMale = [[[UserManager defaultManager] gender] isEqualToString:@"m"];
    }
        

    UIImage *defaultImage = nil;
    if (isMale) {
        defaultImage = [[ShareImageManager defaultManager] maleDefaultAvatarImage];
    }else{
        defaultImage = [[ShareImageManager defaultManager] femaleDefaultAvatarImage];
    }
    
    if([avatar length] != 0){
        NSURL *url = [NSURL URLWithString:avatar];
//        self.avatarView.alpha = 0;
//        [self.avatarView setImageWithURL:url placeholderImage:defaultImage success:NULL failure:NULL];
        [self.avatarView setImageWithURL:url placeholderImage:defaultImage];
    } else{
        [self.avatarView setImage:defaultImage];
    }
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
    
    //adjust time label and content
    [self.timeButton setHidden:!showTime];
    CGFloat startY = [ChatDetailCell contentStartY:showTime];
    NSArray *updateViews = [NSArray arrayWithObjects:self.avatarButton,self.contentButton, nil];
    [self setViews:updateViews yOrigin:startY];
    if (showTime) {
        [self updateTime:message.createDate];
    }

    if (message.messageType != MessageTypeDraw) {
        [self.showDrawView removeFromSuperview];
    }
    
    [self.contentButton setImage:nil forState:UIControlStateNormal];
    
    if (message.messageType == MessageTypeText || message.messageType == MessageTypeLocationRequest || message.messageType == MessageTypeLocationResponse) {
        [self updateTextMessageView:(TextMessage *)message];
        
    }else if(message.messageType == MessageTypeDraw){
        [self updateDrawMessageView:(DrawMessage *)message];
    } else if(message.messageType == MessageTypeImage){
        [self updateImageMessageView:(ImageMessage*)message];
    }
    
    //如果是发送的消息就靠右
    if (!_isReceive) {
        CGPoint rightTop = self.avatarButton.frame.origin;
        rightTop.x -= SPACE_AVATAR_CONTENT;
        [self updateView:self.contentButton rightTop:rightTop];
        CGPoint origin = self.contentButton.frame.origin;
        origin.x += BUBBLE_NOT_TIP_WIDTH;
        origin.y += TEXT_VERTICAL_EDGE;
        [self updateView:self.showDrawView.superview origin:origin];
        
        [self updateSendingFlag:_message.status];
    }
    [self updateAvatarImage:messageStat];
}


#pragma mark action
- (IBAction)clickAvatarButton:(id)sender {
    if (_isReceive) {
        MyFriend *friend = [MyFriend friendWithFid:_messageStat.friendId 
                                          nickName:_messageStat.friendNickName 
                                            avatar:_messageStat.friendAvatar
                                            gender:_messageStat.friendGenderString 
                                             level:1];
        if (self.delegate && [self.delegate respondsToSelector:@selector(showFriendProfile:)]) {
            [self.delegate showFriendProfile:friend];
        }
    }
}

- (IBAction)clickContentButton:(id)sender {
    if ([delegate respondsToSelector:@selector(clickMessage:)]) {
        [delegate clickMessage:self.message];
    }
}

- (void)longPressContentButton:(id)sender
{
    //show the action sheet to show the options
    if (delegate && [delegate respondsToSelector:@selector(didLongClickMessage:)]) {
        [delegate didLongClickMessage:self.message];
    }
}

@end
