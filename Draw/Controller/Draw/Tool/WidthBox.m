//
//  WidthBox.m
//  Draw
//
//  Created by gamy on 13-2-1.
//
//

#import "WidthBox.h"
#import "WidthView.h"
#import "ConfigManager.h"

@interface WidthBox()
{
//    NSMutableArray *widthViewList;
}
@end

@implementation WidthBox
@synthesize delegate = _delegate;

#define VIEW_WIDTH ([WidthView width] + 2)


#define WIDTH_END (-1)

+ (NSInteger)countOfList:(NSInteger *)list
{
    NSInteger *value = list;
    NSInteger count = 0;
    while (value != NULL && *value != WIDTH_END) {
        count ++;
        value ++;
    }
    return count;
}

//- (void)addAction

- (void)clickWidthView:(WidthView *)widthView
{
    [self setWidthSelected:widthView.width];
    if (self.delegate && [self.delegate respondsToSelector:@selector(widthBox:didSelectWidth:)]) {
        [self.delegate widthBox:self didSelectWidth:widthView.width];
    }
}

- (void)addActionToWidthView:(WidthView *)view
{
    [view addTarget:self action:@selector(clickWidthView:) forControlEvents:UIControlEventTouchUpInside];

}

+ (id)widthBoxWithWidthList:(NSInteger *)list
{
    WidthBox *view = [[[WidthBox alloc] initWithFrame:CGRectZero] autorelease];
    [view setBackgroundColor:[UIColor clearColor]];
    
    NSInteger count = [WidthBox countOfList:list];
    CGFloat height = count * [WidthView width];
    CGFloat width = [WidthView width];
    view.frame = CGRectMake(0, 0, width, height);
    CGFloat y = width / 2;
    CGFloat x = CGRectGetMidX(view.frame);
    
    for (NSInteger *value = list; value != NULL && (*value) != WIDTH_END; value++ ) {
        NSInteger w = *value;
        WidthView *wv = [WidthView viewWithWidth:w];
        wv.center = CGPointMake(x, y);
        [view addActionToWidthView:wv];
        [view addSubview:wv];
        y += CGRectGetHeight(wv.bounds);
    }
    return view;
}

+ (id)widthBox
{
    return [WidthBox widthBoxWithWidthList:[ConfigManager penWidthList]];
}

- (void)setWidthSelected:(CGFloat)width
{
    for (WidthView *view in self.subviews) {
        if ([view isKindOfClass:[WidthView class]]) {
            if (abs(view.width - width) < 0.5) {
                view.selected = YES;
            }else{
                view.selected = NO;
            }
        }
    }
}

- (void)dealloc{
    PPDebug(@"%@ dealloc",self);
    self.delegate = nil;
    [super dealloc];
}


@end
