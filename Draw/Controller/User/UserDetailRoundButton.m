//
//  UserDetailRoundButton.m
//  Draw
//
//  Created by Kira on 13-4-1.
//
//

#import "UserDetailRoundButton.h"

@implementation UserDetailRoundButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addUpDownLabel];
    }
    return self;
}

- (UILabel*)labelWithFontSize:(UIFont*)font
{
    UILabel* label = [[[UILabel alloc] init] autorelease];
    [label setFont:font];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setUserInteractionEnabled:NO];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    return label;
    
}
- (void)addUpDownLabel
{
    _upLabel = [self labelWithFontSize:self.titleLabel.font];
    _downLabel = [self labelWithFontSize:self.titleLabel.font];
    [_upLabel setFrame:CGRectMake(self.frame.size.width*0.15, self.frame.size.height*0.15, self.frame.size.width*0.7, self.frame.size.height*0.35)];
    [_downLabel setFrame:CGRectMake(self.frame.size.width*0.15, self.frame.size.height/2, self.frame.size.width*0.7, self.frame.size.height*0.35)];
    [self addSubview:_upLabel];
    [self addSubview:_downLabel];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addUpDownLabel];
    }
    return self;
}

- (void)dealloc
{
    [_upLabel release];
    [_downLabel release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
