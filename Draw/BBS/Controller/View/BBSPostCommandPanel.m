//
//  PostCommandPanel.m
//  Draw
//
//  Created by gamy on 13-1-22.
//
//

#import "BBSPostCommandPanel.h"
#import "BBSPostCommand.h"
#import "BBSPostCommandView.h"

#define VIEW_SIZE (ISIPAD ? CGSizeMake(768,87): CGSizeMake(320,40))
#define COMMAND_MAX_COUNT 5

@interface BBSPostCommandPanel()
{

}
@property (nonatomic, retain) NSArray *commandList;
@end

@implementation BBSPostCommandPanel

- (void)dealloc
{
    PPRelease(_commandList);
    [super dealloc];
}

- (CGFloat)spaceOfCommandViews:(NSInteger)commandCount
{
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat viewWith = [BBSPostCommandView viewWidth] * commandCount;
    return (width-viewWith)/commandCount;
}

- (void)updateView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

    NSInteger count = [self.commandList count];
    if (count == 0) {
        return;
    }
    CGFloat space = ([self spaceOfCommandViews:count]);
    CGFloat viewWidth = [BBSPostCommandView viewWidth];
    CGFloat x = CGRectGetWidth(self.bounds) - count * viewWidth - (count - 1)*space;
    
    x /= 2;
    
    for (BBSPostCommand *command in self.commandList) {
        BBSPostCommandView *view = [BBSPostCommandView commandViewWithCommand:command];
        [self addSubview:view];
        view.center = self.center;
        CGRect rect = view.frame;
        rect.origin.x = x;
        view.frame = rect;
        x += (viewWidth+space);
    }
}

- (id)initWithCommandList:(NSArray *)commandList
{
    CGRect rect = CGRectZero;
    rect.size = VIEW_SIZE;
    self = [super initWithFrame:rect];
    if (self) {
        self.commandList = commandList;
        [self updateView];
    }
    return self;
}

+ (id)panelWithCommandList:(NSArray *)commandList
{
    return [[[BBSPostCommandPanel alloc] initWithCommandList:commandList] autorelease];
}

@end
