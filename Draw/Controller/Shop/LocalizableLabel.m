//
//  LocalizableLabel.m
//  Draw
//
//  Created by 王 小涛 on 13-3-6.
//
//

#import "LocalizableLabel.h"

@implementation LocalizableLabel

- (void)setText:(NSString *)text
{
    [super setText:NSLS(text)];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setText:self.text];
    }
    
    return self;
}

@end
