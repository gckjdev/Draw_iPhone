//
//  DiceSelectedView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceSelectedView.h"
#import "UIViewUtils.h"
#import "FontButton.h"
#import "DiceImageManager.h"

#define DEFAULT_HEIGHT_OF_PAGE_CONTROL 20

#define EACH_PAGE_BUTTON_COUNT 7
#define EDGE_WIDTH 4

@implementation DiceSelectedView

@synthesize pageControl;

- (void)dealloc
{
    [pageControl release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:207.0/255.0  blue:207.0/255.0  alpha:1];
        self.delegate = self;
        
        self.pageControl = [[UICustomPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x/2, self.bounds.size.height-DEFAULT_HEIGHT_OF_PAGE_CONTROL, self.bounds.size.width, DEFAULT_HEIGHT_OF_PAGE_CONTROL)]; 
        self.backgroundColor = [UIColor clearColor];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.delegate = self;
        
        [self addSubview:self.pageControl];
    }
    
    return self;
}

- (void)setStart:(int)start end:(int)end
{
    int viewCount = (end - start + 1) / 7 + ((((end - start + 1) % 7) == 0) ? 0 : 1);
    if (viewCount <=  2) {
        viewCount = 1;
    }else {
        viewCount = 2;
    }
    
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:viewCount];
    UIView *view;
    
    int startNum = start;
    int endNum;
    
    for (int i = 0; i < viewCount; i ++) {
        endNum = (end - startNum + 1 > EACH_PAGE_BUTTON_COUNT) ? startNum + EACH_PAGE_BUTTON_COUNT - 1 : end;
        view = [self pageViewWithStart:startNum end:endNum];
        
        [views addObject:view];
    }
    
    [self setViews:views];
}

- (void)setViews:(NSArray*)views
{
    [self removeAllSubviews];
    
    int count = [views count];
    self.contentSize = CGSizeMake(self.bounds.size.width * count, self.bounds.size.height);

    for (int i = 0; i < count; i ++) {
        UIView *view = [views objectAtIndex:i];

        view.frame = CGRectMake(self.bounds.size.width * i, 0, view.bounds.size.width, view.bounds.size.height);
        
        [self addSubview:view];
    }
    
    pageControl.numberOfPages = count;
}


#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /* we switch page at %50 across */
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth +1);
    pageControl.currentPage = page;
}

#pragma mark -
#pragma mark PageControl stuff
- (void)currentPageDidChange:(int)newPage;
{
    // Change the scroll view 
    CGRect frame = self.frame;
    frame.origin.x  = frame.size.width * newPage;
    frame.origin.y = 0;
    [self scrollRectToVisible:frame animated:YES];
}

- (UIView *)pageViewWithStart:(int)start end:(int)end
{
    UIView *view = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
    
    CGRect frame;
//    int width = (view.bounds.size.width - EDGE_WIDTH) / EACH_PAGE_BUTTON_COUNT - EDGE_WIDTH;
    int width = 30;
    int height = 32;

    int j = 0;
    for (int i = start; i <= end; i ++) {
        frame = CGRectMake(EDGE_WIDTH + (EDGE_WIDTH + width) * j++, 0, width, height);
        UIButton * button = [self diceCountSelectedButtonWithFrame:frame num:i];
        [view addSubview:button];
    }
    
    return view;
}

- (UIButton *)diceCountSelectedButtonWithFrame:(CGRect)frame num:(int)num
{
    FontButton *fontButton = [[[FontButton alloc] initWithFrame:frame 
                                                       fontName:@"diceFont"
                                                      pointSize:25] autorelease];
    fontButton.fontLable.text = [NSString stringWithFormat:@"%d", num];
    fontButton.tag = num;
    
    [fontButton addTarget:self 
                   action:@selector(clickCountSelectedButton:)
         forControlEvents:UIControlEventTouchUpInside];
    [fontButton setBackgroundImage:[[DiceImageManager defaultManager] diceCountSelectedBtnBgImage] forState:UIControlStateNormal];
    
    return fontButton;
}

- (void)clickCountSelectedButton:(id)sender
{
    
}



@end
