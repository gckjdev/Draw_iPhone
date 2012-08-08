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
#import "PPDebug.h"
#import "DiceFontManager.h"

#define DEFAULT_HEIGHT_OF_PAGE_CONTROL 5

#define EACH_PAGE_BUTTON_COUNT 7
#define EDGE_WIDTH 4

@interface DiceSelectedView ()
{
    int _startDice;
    int _start;
    BOOL _userInteraction;
}

@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) UIView *superView;

@property (retain, nonatomic) CMPopTipView *popView;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UICustomPageControl *pageControl;

@property (retain, nonatomic) UIButton *curSelecetedDiceCountBtn;

@end

@implementation DiceSelectedView

@synthesize delegate = _delegate;

@synthesize timer = _timer;
@synthesize superView = _superView;

@synthesize popView = _popView;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize curSelecetedDiceCountBtn = _curSelecetedDiceCountBtn;


- (void)dealloc
{
    [_timer release];
    [_superView release];
    [_popView release];
    [_scrollView release];
    [_pageControl release];
    [_curSelecetedDiceCountBtn release]; 
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.superView = superView;
        _startDice = 1;
        
        self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.delegate = self;
        
        self.pageControl = [[[UICustomPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x/2, self.bounds.size.height-DEFAULT_HEIGHT_OF_PAGE_CONTROL - 3, self.bounds.size.width, DEFAULT_HEIGHT_OF_PAGE_CONTROL)] autorelease]; 
        self.backgroundColor = [UIColor clearColor];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.delegate = self;
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    
    return self;
}

- (void)setStart:(int)start end:(int)end startDice:(int)startDice
{
    start = (start < 1) ? 1 : start;
    end = (end < 7) ? 7 : end;

    _start = start;
    _startDice = startDice;
    
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

- (void)disableUserInteraction
{
    for (UIView *pageView in [self.scrollView subviews]) {
        for (UIView *view in [pageView subviews]) {
            if ([view isKindOfClass:[FontButton class]]) {
                FontButton *button = (FontButton *)view;
                button.enabled = NO;
            }
        }
    }
}
- (void)enableUserInteraction
{
    for (UIView *pageView in [self.scrollView subviews]) {
        for (UIView *view in [pageView subviews]) {
            if ([view isKindOfClass:[FontButton class]]) {
                FontButton *button = (FontButton *)view;
                button.enabled = YES;
            }
        }
    }
}


#pragma mark - Private methods

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

#pragma mark - Timer manage

- (void)createTimer
{
    [self killTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                  target:self 
                                                selector:@selector(handleTimer:)
                                                userInfo:nil 
                                                 repeats:NO];
}

- (void)killTimer
{
    if ([_timer isValid]) {
        [_timer invalidate];        
    }
    self.timer = nil;
}

- (void)handleTimer:(NSTimer *)timer
{
    [self.popView dismissAnimated:YES];
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
                                                       fontName:[[DiceFontManager defaultManager] fontName]
                                                      pointSize:25] autorelease];
    fontButton.fontLable.text = [NSString stringWithFormat:@"%d", num];
    fontButton.tag = num;
    
    [fontButton addTarget:self 
                   action:@selector(clickCountSelectedButton:)
         forControlEvents:UIControlEventTouchUpInside];
    [fontButton setBackgroundImage:[[DiceImageManager defaultManager] diceCountBtnBgImage] forState:UIControlStateNormal];
    [fontButton setBackgroundImage:[[DiceImageManager defaultManager] diceCountSelectedBtnBgImage] forState:UIControlStateSelected];
    
    fontButton.enabled = NO;
    
    return fontButton;
}

- (void)clickCountSelectedButton:(id)sender
{    
    [self createTimer];
    [self.popView dismissAnimated:YES];
    
    self.curSelecetedDiceCountBtn = (UIButton *)sender;
    _curSelecetedDiceCountBtn.selected = YES;
    
    NSArray *diceList;

    if (_curSelecetedDiceCountBtn.tag == _start) {
        diceList = [self genDiceListStartWith:_startDice  end:6];
    }else {
        diceList = [self genDiceListStartWith:1 end:6];
    }
    
    DiceShowView *diceShowView = [[DiceShowView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) dices:diceList userInterAction:YES];
    diceShowView.delegate = self;
    
    self.popView = [[[CMPopTipView alloc] initWithCustomView:diceShowView] autorelease];
    self.popView.delegate = self;
    self.popView.backgroundColor = [UIColor colorWithRed:233./255. green:235./255. blue:189./255. alpha:0.5];
    [self.popView presentPointingAtView:(UIButton *)sender inView:self.superView animated:YES];
//    [_popView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:3];
}

- (NSArray *)genDiceListStartWith:(int)start end:(int)end
{
    NSMutableArray *dices = [NSMutableArray array];

    for (int i = start; i <= end; i ++) {
        PBDice_Builder *diceBuilder = [[[PBDice_Builder alloc] init] autorelease];
        [diceBuilder setDice:i];
        [diceBuilder setDiceId:i];
        PBDice *dice = [diceBuilder build];
         
        [dices addObject:dice];
    }
    
    return dices;
}

#pragma mark - DiceShowViewDelegate

- (void)didSelectedDice:(PBDice *)dice
{    
    [self.popView dismissAnimated:YES];
    _curSelecetedDiceCountBtn.selected = NO;
    
    PPDebug(@"Call %d * %d", _curSelecetedDiceCountBtn.tag, dice.dice);
    if ([_delegate respondsToSelector:@selector(didSelectedDice:count:)]) {
        [_delegate didSelectedDice:dice count:_curSelecetedDiceCountBtn.tag];
    }
}

#pragma mark - CMPopTipViewDelegate

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    _curSelecetedDiceCountBtn.selected = NO;
}

- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    _curSelecetedDiceCountBtn.selected = NO;
}

@end
