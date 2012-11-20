//
//  MessageView.m
//  Draw
//
//  Created by 王 小涛 on 12-11-12.
//
//

#import "MessageView.h"
#import "FXLabel.h"

#define MESSAGE_MAX_WIDTH 200
#define MESSAGE_MIN_WIDTH 30
#define MESSAGE_MAX_HEIGHT MAXFLOAT
#define MESSAGE_MIN_HEIGHT 20

#define LABEL_LEFT_OFFSET ([DeviceDetection isIPAD] ? 5.0 : 2.5)
#define LABEL_RIGHT_OFFSET ([DeviceDetection isIPAD] ? 5.0 : 2.5)
#define LABEL_TOP_OFFSET ([DeviceDetection isIPAD] ? 3 : 1)
#define LABEL_BOTTOM_OFFSET ([DeviceDetection isIPAD] ? 13 : 7)


#define LABEL_TAG 200
#define BACKGROUND_IMAGE_VIEW_TAG 201


@implementation MessageView

- (void)dealloc {
    [super dealloc];
}

+ messageViewWithMessage:(NSString *)message
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
           textAlignment:(UITextAlignment)textAlignment
                 bgImage:(UIImage*)bgImage
{
    return [[[MessageView alloc] initWithMessage:message
                                            font:font
                                       textColor:textColor
                                   textAlignment:textAlignment
                                         bgImage:bgImage] autorelease];
}

- (id)initWithMessage:(NSString *)message
                 font:(UIFont *)font
            textColor:(UIColor *)textColor
        textAlignment:(UITextAlignment)textAlignment
              bgImage:(UIImage*)bgImage
{
    if (self = [super init]) {
        FXLabel *label = [self labelWithMessage:message
                                           font:font
                                      textColor:textColor
                                  textAlignment:textAlignment];

        label.tag = LABEL_TAG;
        label.frame = CGRectMake(LABEL_LEFT_OFFSET, LABEL_TOP_OFFSET, label.frame.size.width, label.frame.size.height);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, LABEL_LEFT_OFFSET + label.frame.size.width + LABEL_RIGHT_OFFSET, LABEL_TOP_OFFSET + label.frame.size.height + LABEL_BOTTOM_OFFSET)] autorelease];
        imageView.tag = BACKGROUND_IMAGE_VIEW_TAG;
        imageView.image = bgImage;
        
        self.frame = imageView.frame;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        [self addSubview:label];
    }
    
    return self;
}

- (FXLabel *)labelWithMessage:(NSString *)message
                         font:(UIFont *)font
                    textColor:(UIColor *)textColor
                textAlignment:(UITextAlignment)textAlignment
{
    CGSize withSize = CGSizeMake(MESSAGE_MAX_WIDTH, MAXFLOAT);
    UILineBreakMode mode = [LocaleUtils isChinese] ? UILineBreakModeCharacterWrap : UILineBreakModeWordWrap;
    CGSize size = [message sizeWithFont:font constrainedToSize:withSize lineBreakMode:mode];
    size.width = (size.width < MESSAGE_MIN_WIDTH) ? MESSAGE_MIN_WIDTH : size.width;
//    size.width = size.width * 1.1;
    size.height = (size.height < MESSAGE_MIN_HEIGHT) ? MESSAGE_MIN_HEIGHT : size.height;
    
    if([DeviceDetection isIPAD])
    {
        size.width *= 1.5;
        size.height *= 1.0;
    }

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
