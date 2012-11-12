//
//  MessageView.m
//  Draw
//
//  Created by 王 小涛 on 12-11-12.
//
//

#import "MessageView.h"

#define MESSAGE_MAX_WIDTH 200
#define MESSAGE_MIN_WIDTH 20
#define LABEL_LEFT_OFFSET 5
#define LABEL_RIGHT_OFFSET 3
#define LABEL_TOP_OFFSET 2
#define LABEL_BOTTOM_OFFSET 5


#define LABEL_TAG 200
#define BACKGROUND_IMAGE_VIEW_TAG 201


@implementation MessageView


- (void)dealloc {
    [super dealloc];
}

+ messageViewWithMessage:(NSString *)message
                    font:(UIFont *)font
           textAlignment:(UITextAlignment)textAlignment
                 bgImage:(UIImage*)bgImage
{
    return [[[MessageView alloc] initWithMessage:message
                                            font:font
                                   textAlignment:textAlignment
                                         bgImage:bgImage] autorelease];
}

- (id)initWithMessage:(NSString *)message
                 font:(UIFont *)font
        textAlignment:(UITextAlignment)textAlignment
              bgImage:(UIImage*)bgImage
{
    if (self = [super init]) {
        UILabel *label = [self labelWithMessage:message
                                           font:font
                                  textAlignment:textAlignment];
        label.tag = LABEL_TAG;
        label.frame = CGRectMake(LABEL_LEFT_OFFSET, LABEL_TOP_OFFSET, label.frame.size.width, label.frame.size.height);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, LABEL_LEFT_OFFSET + label.frame.size.width + LABEL_RIGHT_OFFSET, LABEL_TOP_OFFSET + label.frame.size.height + LABEL_BOTTOM_OFFSET)] autorelease];
        imageView.tag = BACKGROUND_IMAGE_VIEW_TAG;
        imageView.image = bgImage;
        [self addSubview:label];
        [self addSubview:imageView];
    }
    
    return self;
}

- (UILabel *)labelWithMessage:(NSString *)message
                         font:(UIFont *)font
                textAlignment:(UITextAlignment)textAlignment
{
    CGSize withSize = CGSizeMake(MESSAGE_MAX_WIDTH, MAXFLOAT);
    UILineBreakMode mode = [LocaleUtils isChinese] ? UILineBreakModeCharacterWrap : UILineBreakModeWordWrap;
    CGSize size = [message sizeWithFont:font constrainedToSize:withSize lineBreakMode:mode];
    size.width = (size.width < MESSAGE_MIN_WIDTH) ? MESSAGE_MIN_WIDTH : size.width;
    size.width = size.width * 1.1;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[[UILabel alloc] initWithFrame:rect] autorelease];
    
    label.text = message;
    label.lineBreakMode = mode;
    label.textAlignment = textAlignment;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}


@end
