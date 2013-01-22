//
//  PostCommandView.m
//  Draw
//
//  Created by gamy on 13-1-22.
//
//

#import "BBSPostCommandView.h"
#import "BBSPostCommand.h"

#define VIEW_SIZE (ISIPAD ? CGSizeMake(48,52): CGSizeMake(24,26))

@implementation BBSPostCommandView

- (void)dealloc
{
    PPRelease(_command);
    [super dealloc];
}

- (void)clickView:(id)sender
{
    [self.command excute];
}
- (id)initWithWithCommand:(BBSPostCommand *)command
{
    CGRect rect = CGRectZero;
    rect.size = VIEW_SIZE;
    self = [super initWithFrame:rect];
    if (self) {
        self.command = command;
        [self addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
        [self setImage:command.icon forState:UIControlStateNormal];
    }
    return self;
}

+ (id)commandViewWithCommand:(BBSPostCommand *)command
{
    return [[[BBSPostCommandView alloc] initWithWithCommand:command] autorelease];
}
+ (CGFloat)viewWidth
{
    return VIEW_SIZE.width;
}

@end
