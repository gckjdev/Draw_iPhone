//
//  MessageView.m
//  Draw
//
//  Created by 王 小涛 on 12-11-12.
//
//

#import "MessageView.h"
#import "FXLabel.h"

typedef struct{
    CGFloat leftOffset;
    CGFloat rightOffset;
    CGFloat topOffset;
    CGFloat bottomOffset;
} Offset;

#define ACTION_MESSAGE_MAX_WIDTH 200
#define ACTION_MESSAGE_MIN_WIDTH 30
#define ACTION_MESSAGE_MAX_HEIGHT 50
#define ACTION_MESSAGE_MIN_HEIGHT 20

#define CHAT_MESSAGE_MAX_WIDTH ([DeviceDetection isIPAD] ? 200 : 100)
#define CHAT_MESSAGE_MIN_WIDTH 30
#define CHAT_MESSAGE_MAX_HEIGHT ([DeviceDetection isIPAD] ? 300 : 150)
#define CHAT_MESSAGE_MIN_HEIGHT 20

#define ACTION_MESSAGE_LABEL_LEFT_OFFSET ([DeviceDetection isIPAD] ? 10.0 : 2.5)
#define ACTION_MESSAGE_LABEL_RIGHT_OFFSET ([DeviceDetection isIPAD] ? 10.0 : 2.5)
#define ACTION_MESSAGE_LABEL_TOP_OFFSET ([DeviceDetection isIPAD] ? 5 : 1)
#define ACTION_MESSAGE_LABEL_BOTTOM_OFFSET ([DeviceDetection isIPAD] ? 11 : 7)

//#define CHAT_MESSAGE_LABEL_LEFT_OFFSET ([DeviceDetection isIPAD] ? 5.0 : 2.5)
//#define CHAT_MESSAGE_LABEL_RIGHT_OFFSET ([DeviceDetection isIPAD] ? 5.0 : 2.5)
//#define CHAT_MESSAGE_LABEL_TOP_OFFSET ([DeviceDetection isIPAD] ? 5 : 1)
//#define CHAT_MESSAGE_LABEL_BOTTOM_OFFSET ([DeviceDetection isIPAD] ? 11 : 7)


#define ACTION_MESSAGE_LABEL_TAG 200
#define ACTION_MESSAGE_BACKGROUND_IMAGE_VIEW_TAG 201


@implementation MessageView

- (void)dealloc {
    [super dealloc];
}

+ actionMessageViewWithMessage:(NSString *)message
                          font:(UIFont *)font
                     textColor:(UIColor *)textColor
                 textAlignment:(UITextAlignment)textAlignment
                       bgImage:(UIImage*)bgImage
{
    return [[[MessageView alloc] initWithActionMessage:message
                                                  font:font
                                             textColor:textColor
                                         textAlignment:textAlignment
                                               bgImage:bgImage] autorelease];
}   

+ chatMessageViewWithMessage:(NSString *)message
                        font:(UIFont *)font
                   textColor:(UIColor *)textColor
               textAlignment:(UITextAlignment)textAlignment
                     bgImage:(UIImage*)bgImage
                         pos:(UserPosition)pos
{
    return [[MessageView alloc] initWithChatMessage:message
                                               font:font
                                          textColor:textColor
                                      textAlignment:textAlignment
                                            bgImage:bgImage
                                                pos:pos];
}


- (id)initWithActionMessage:(NSString *)message
                       font:(UIFont *)font
                  textColor:(UIColor *)textColor
              textAlignment:(UITextAlignment)textAlignment
                    bgImage:(UIImage*)bgImage
{
    if (self = [super init]) {
        FXLabel *label = [self labelWithMessage:message
                                           font:font
                                       maxWidth:ACTION_MESSAGE_MAX_WIDTH
                                      maxHeight:ACTION_MESSAGE_MAX_HEIGHT
                                      textColor:textColor
                                  textAlignment:textAlignment];
        
        label.tag = ACTION_MESSAGE_LABEL_TAG;
        label.frame = CGRectMake(ACTION_MESSAGE_LABEL_LEFT_OFFSET, ACTION_MESSAGE_LABEL_TOP_OFFSET, label.frame.size.width, label.frame.size.height);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ACTION_MESSAGE_LABEL_LEFT_OFFSET + label.frame.size.width + ACTION_MESSAGE_LABEL_RIGHT_OFFSET, ACTION_MESSAGE_LABEL_TOP_OFFSET + label.frame.size.height + ACTION_MESSAGE_LABEL_BOTTOM_OFFSET)] autorelease];
        imageView.tag = ACTION_MESSAGE_BACKGROUND_IMAGE_VIEW_TAG;
        imageView.image = bgImage;
        
        self.frame = imageView.frame;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        [self addSubview:label];
    }
    
    return self;
}

- (id)initWithChatMessage:(NSString *)message
                     font:(UIFont *)font
                textColor:(UIColor *)textColor
            textAlignment:(UITextAlignment)textAlignment
                  bgImage:(UIImage*)bgImage
                      pos:(UserPosition)pos
{
    if (self = [super init]) {
        FXLabel *label = [self labelWithMessage:message
                                           font:font
                                       maxWidth:CHAT_MESSAGE_MAX_WIDTH
                                      maxHeight:CHAT_MESSAGE_MAX_HEIGHT
                                      textColor:textColor
                                  textAlignment:textAlignment];
       
        Offset offset = [self getOffsetWithPos:pos];

        label.frame = CGRectMake(offset.leftOffset, offset.topOffset, label.frame.size.width, label.frame.size.height);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, offset.leftOffset + label.frame.size.width + offset.rightOffset, offset.topOffset + label.frame.size.height + offset.bottomOffset)] autorelease];
        imageView.image = bgImage;
        
        self.frame = imageView.frame;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        [self addSubview:label];
    }
    
    return self;
}

- (Offset)getOffsetWithPos:(UserPosition)pos
{
    Offset offset;
    switch (pos) {
        case UserPositionCenter:
            offset.leftOffset = ([DeviceDetection isIPAD] ? 14 : 7);
            offset.rightOffset = ([DeviceDetection isIPAD] ? 14 : 7);
            offset.topOffset = ([DeviceDetection isIPAD] ? 12 : 6);
            offset.bottomOffset = ([DeviceDetection isIPAD] ? 15 : 10);
            break;
            
        case UserPositionCenterUp:
            offset.leftOffset = ([DeviceDetection isIPAD] ? 14 : 5);
            offset.rightOffset = ([DeviceDetection isIPAD] ? 14 : 5);
            offset.topOffset = ([DeviceDetection isIPAD] ? 15 : 10);
            offset.bottomOffset = ([DeviceDetection isIPAD] ? 12 : 6);
            break;
            
        case UserPositionLeft:
        case UserPositionLeftTop:
            offset.leftOffset = ([DeviceDetection isIPAD] ? 15 : 10);
            offset.rightOffset = ([DeviceDetection isIPAD] ? 12 : 6);
            offset.topOffset = ([DeviceDetection isIPAD] ? 14 : 5);
            offset.bottomOffset = ([DeviceDetection isIPAD] ? 14 : 5);
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            offset.leftOffset = ([DeviceDetection isIPAD] ? 12 : 6);
            offset.rightOffset = ([DeviceDetection isIPAD] ? 15 : 10);
            offset.topOffset = ([DeviceDetection isIPAD] ? 14 : 5);
            offset.bottomOffset = ([DeviceDetection isIPAD] ? 14 : 5);
            break;
            
        default:
            break;
    }
    
    return offset;
}

- (FXLabel *)labelWithMessage:(NSString *)message
                         font:(UIFont *)font
                     maxWidth:(CGFloat)maxWidth
                    maxHeight:(CGFloat)maxHeight
                    textColor:(UIColor *)textColor
                textAlignment:(UITextAlignment)textAlignment
{
    CGSize withSize = CGSizeMake(maxWidth, maxHeight);
    UILineBreakMode mode = [LocaleUtils isChinese] ? UILineBreakModeCharacterWrap : UILineBreakModeWordWrap;
    CGSize size = [message sizeWithFont:font constrainedToSize:withSize lineBreakMode:mode];
    size.width = (size.width < ACTION_MESSAGE_MIN_WIDTH) ? ACTION_MESSAGE_MIN_WIDTH : size.width;
//    size.width = size.width * 1.1;
    size.height = (size.height < ACTION_MESSAGE_MIN_HEIGHT) ? ACTION_MESSAGE_MIN_HEIGHT : size.height;
    
//    if([DeviceDetection isIPAD])
//    {
//        size.width *= 1.5;
//        size.height *= 1.0;
//    }

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    FXLabel *label = [[[FXLabel alloc] initWithFrame:rect] autorelease];
    label.font = font;
    label.text = message;
    label.lineBreakMode = mode;
    label.textAlignment = textAlignment;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    
    label.textColor = textColor;
    
    return label;
}


@end
