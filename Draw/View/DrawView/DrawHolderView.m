//
//  DrawHolderView.m
//  Draw
//
//  Created by gamy on 13-3-15.
//
//

#import "DrawHolderView.h"
#import "UIViewUtils.h"
#import "DrawView.h"
#import "ShowDrawView.h"
#import "UIViewUtils.h"
#import "CanvasRect.h"

@implementation DrawHolderView

- (void)dealloc{
    PPDebug(@"<DrawHolderView> dealloc");
    [_contentView removeFromSuperview];
    PPRelease(_contentView);
    [super dealloc];
}

- (DrawView *)drawView{
    if ([_contentView isKindOfClass:[DrawView class]]) {
        return (DrawView *)_contentView;
    }
    return nil;
}
- (ShowDrawView *)showView{
    if ([_contentView isKindOfClass:[ShowDrawView class]]) {
        return (ShowDrawView *)_contentView;
    }
    return nil;
}

- (void)updateContentScale
{
    CGFloat xScale = CGRectGetWidth(self.bounds) / CGRectGetWidth(_contentView.bounds);
    CGFloat yScale = CGRectGetHeight(self.bounds) / CGRectGetHeight(_contentView.bounds);
    CGFloat scale = MIN(xScale, yScale);
    _contentView.scale = scale;
    _contentView.center = CGRectGetCenter(self.bounds);
    _contentView.minScale = _contentView.scale;
    PPDebug(@"<updateContentScale> scale = %f",scale);
    
}
- (void)setContentView:(SuperDrawView *)contentView{
    
    if (_contentView != contentView) {
        [_contentView removeFromSuperview];
        PPRelease(_contentView);
        _contentView = [contentView retain];
        [self addSubview:_contentView];
    }
    [self updateContentScale];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (id)drawHolderViewWithFrame:(CGRect)frame
                    contentView:(SuperDrawView *)contentView{
    DrawHolderView *holder = [[DrawHolderView alloc] initWithFrame:frame];
    [holder setContentView:contentView];
    return [holder autorelease];
}



+ (id)defaultDrawHolderViewWithContentView:(SuperDrawView *)contentView
{
    CGRect frame = [CanvasRect defaultRect];
    if (ISIPAD) {
        frame.origin = CGPointMake((768.0f-frame.size.width)/2.0, 98);
    }else if(ISIPHONE5){
        frame.origin = CGPointMake((320.0f-frame.size.width)/2.0, 50);
    }else{
        frame.origin = CGPointMake((320.0f-frame.size.width)/2.0, 42);
    }
    frame.origin.y += +STATUSBAR_DELTA;

    return [DrawHolderView drawHolderViewWithFrame:frame contentView:contentView];
}

@end
