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
#import "DiceShowView.h"
#import "CMPopTipView.h"

#define DEFAULT_HEIGHT_OF_PAGE_CONTROL 20

#define EACH_PAGE_BUTTON_COUNT 7
#define EDGE_WIDTH 4

@interface DiceSelectedView ()

@property (retain, nonatomic) UIView *superView;

@property (retain, nonatomic) CMPopTipView *popView;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UICustomPageControl *pageControl;

@property (retain, nonatomic) NSArray *diceList;

@end

@implementation DiceSelectedView

@synthesize superView = _superView;

@synthesize popView = _popView;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize diceList = _diceList;

- (void)dealloc
{
    [_superView release];
    [_popView release];
    [_scrollView release];
    [_pageControl release];
    [_diceList release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.superView = superView;
        
        self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.delegate = self;
        
        self.pageControl = [[UICustomPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x/2, self.bounds.size.height-DEFAULT_HEIGHT_OF_PAGE_CONTROL, self.bounds.size.width, DEFAULT_HEIGHT_OF_PAGE_CONTROL)]; 
        self.backgroundColor = [UIColor clearColor];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.delegate = self;
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        
        self.diceList = [self genDiceList];
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
        startNum = endNum + 1;
        
        [views addObject:view];
    }
    
    [self setViews:views];
}

- (void)setViews:(NSArray*)views
{
    [self.scrollView removeAllSubviews];
    
    int count = [views count];
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * count, self.bounds.size.height);

    for (int i = 0; i < count; i ++) {
        UIView *view = [views objectAtIndex:i];

        view.frame = CGRectMake(self.bounds.size.width * i, 0, view.bounds.size.width, view.bounds.size.height);
        
        [_scrollView addSubview:view];
    }
    
    _pageControl.numberOfPages = count;
}


#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /* we switch page at %50 across */
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth +1);
    _pageControl.currentPage = page;
}

#pragma mark -
#pragma mark PageControl stuff
- (void)currentPageDidChange:(int)newPage;
{
    // Change the scroll view 
    CGRect frame = self.frame;
    frame.origin.x  = frame.size.width * newPage;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
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
    DiceShowView *diceShowView = [[DiceShowView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) dices:_diceList userInterAction:YES];
    [self.popView dismissAnimated:YES];
    self.popView = [[CMPopTipView alloc] initWithCustomView:diceShowView];
    self.popView.backgroundColor = [UIColor colorWithRed:233./255. green:235./255. blue:189./255. alpha:0.5];
    [self.popView presentPointingAtView:(UIButton *)sender inView:self.superView animated:YES];
    [self.popView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:3];
}

- (NSArray *)genDiceList
{
    PBDice_Builder *diceBuilder1 = [[[PBDice_Builder alloc] init] autorelease];
    [diceBuilder1 setDice:1];
    [diceBuilder1 setDiceId:1];
    PBDice *dice1 = [diceBuilder1 build];
    
    PBDice_Builder *diceBuilder2 = [[[PBDice_Builder alloc] init] autorelease];
    [diceBuilder2 setDice:2];
    [diceBuilder2 setDiceId:2];
    PBDice *dice2 = [diceBuilder2 build];
    
    PBDice_Builder *diceBuilder3 = [[[PBDice_Builder alloc] init] autorelease];
    [diceBuilder3 setDice:3];
    [diceBuilder3 setDiceId:3];
    PBDice *dice3 = [diceBuilder3 build];
    
    PBDice_Builder *diceBuilder4 = [[[PBDice_Builder alloc] init] autorelease];
    [diceBuilder4 setDice:4];
    [diceBuilder4 setDiceId:4];
    PBDice *dice4 = [diceBuilder4 build];
    
    PBDice_Builder *diceBuilder5 = [[[PBDice_Builder alloc] init] autorelease];
    [diceBuilder5 setDice:5];
    [diceBuilder5 setDiceId:5];
    PBDice *dice5 = [diceBuilder5 build];
    
    PBDice_Builder *diceBuilder6 = [[[PBDice_Builder alloc] init] autorelease];
    [diceBuilder6 setDice:6];
    [diceBuilder6 setDiceId:6];
    PBDice *dice6 = [diceBuilder6 build];
    
    NSArray *dices = [NSArray arrayWithObjects:dice1, dice2, dice3, dice4, dice5, dice6, nil];
    
    return dices;
}




@end
