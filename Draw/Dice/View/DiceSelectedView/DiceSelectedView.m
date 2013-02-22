//
//  DiceSelectedView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceSelectedView.h"
#import "UIViewUtils.h"
#import "DiceImageManager.h"
#import "PPDebug.h"
#import "DiceFontManager.h"

#define DEFAULT_HEIGHT_OF_PAGE_CONTROL ([DeviceDetection isIPAD] ? 10 : 5)

#define EACH_PAGE_BUTTON_COUNT 7
#define EDGE_WIDTH ([DeviceDetection isIPAD] ? 11 : 4)

#define WIDTH_COUNT_BUTTON  ([DeviceDetection isIPAD] ? 68 : 30)
#define HEIGHT_COUNT_BUTTON ([DeviceDetection isIPAD] ? 72 : 32)
#define SIZE_FONT_COUNT_BUTTON  ([DeviceDetection isIPAD] ? 40 : 20)

@interface DiceSelectedView ()
{
    int _lastCallDice;
    int _start;
    int _end;
    BOOL _userInteraction;
}

//@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) UIView *superView;

@property (retain, nonatomic) CMPopTipView *popView;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UICustomPageControl *pageControl;

@property (retain, nonatomic) UIButton *curSelecetedDiceCountBtn;

@end

@implementation DiceSelectedView

@synthesize delegate = _delegate;

//@synthesize timer = _timer;
@synthesize superView = _superView;

@synthesize popView = _popView;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize curSelecetedDiceCountBtn = _curSelecetedDiceCountBtn;


- (void)dealloc
{
//    [_timer release];
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
        _lastCallDice = 1;
        
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
        
        if ([DeviceDetection isIPAD]) {
            self.pageControl.transform = CGAffineTransformMakeScale(1.7, 1.7);
            self.pageControl.center = CGPointMake(self.center.x, self.pageControl.center.y);
        }
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    
    return self;
}

- (void)setLastCallDice:(int)lastCallDice
      lastCallDiceCount:(int)lastCallDiceCount
       playingUserCount:(int)playingUserCount
           maxCallCount:(int)maxCallCount
{
    _lastCallDice = (lastCallDice < 1 || lastCallDice > 6) ? 1 : lastCallDice;
    
    _start = (lastCallDice == 1) ? (lastCallDiceCount + 1) : lastCallDiceCount;
    _end = maxCallCount;
    
    // For protest
    _start = (_start < playingUserCount) ? playingUserCount : _start;
    _end = (_end < 7) ? 7 : _end;
    
    [self setStart];
}


- (void)setStart
{
    int pageCount = (_end - _start + 1) / 7 + ((((_end - _start + 1) % 7) == 0) ? 0 : 1);
    if (pageCount <=  2) {
        pageCount = 1;
    }else {
        pageCount = 2;
    }
    
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:pageCount];
    UIView *view;
    
    int startNum = _start;
    int endNum;
    
    for (int i = 0; i < pageCount; i ++) {
        endNum = (_end - startNum + 1 > EACH_PAGE_BUTTON_COUNT) ? startNum + EACH_PAGE_BUTTON_COUNT - 1 : _end;
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
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                button.enabled = NO;
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

            }
        }
    }
}

- (void)enableUserInteraction
{
    for (UIView *pageView in [self.scrollView subviews]) {
        for (UIView *view in [pageView subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                button.enabled = YES;
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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

//- (void)createTimer
//{
//    [self killTimer];
//    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
//                                                  target:self 
//                                                selector:@selector(handleTimer:)
//                                                userInfo:nil 
//                                                 repeats:NO];
//}
//
//- (void)killTimer
//{
//    if ([_timer isValid]) {
//        [_timer invalidate];        
//    }
//    self.timer = nil;
//}
//
//- (void)handleTimer:(NSTimer *)timer
//{
//    [self.popView dismissAnimated:YES];
//}

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

    int width = WIDTH_COUNT_BUTTON;
    int height = HEIGHT_COUNT_BUTTON;

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
    UIButton *fontButton = [[[UIButton alloc] initWithFrame:frame] autorelease];
    [fontButton.titleLabel setFont:[UIFont systemFontOfSize:SIZE_FONT_COUNT_BUTTON]];
    [fontButton setTitle:[NSString stringWithFormat:@"%d", num] forState:UIControlStateNormal] ;
    fontButton.tag = num;
    
    [fontButton addTarget:self 
                   action:@selector(clickCountSelectedButton:)
         forControlEvents:UIControlEventTouchUpInside];
    [fontButton setBackgroundImage:[[DiceImageManager defaultManager] diceCountBtnBgImage] forState:UIControlStateNormal];
    [fontButton setBackgroundImage:[[DiceImageManager defaultManager] diceCountSelectedBtnBgImage] forState:UIControlStateSelected];
    
    fontButton.enabled = NO;
    [fontButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
    return fontButton;
}

- (void)clickCountSelectedButton:(id)sender
{    
//    [self createTimer];
    [self.popView dismissAnimated:YES];
    
    self.curSelecetedDiceCountBtn = (UIButton *)sender;
    _curSelecetedDiceCountBtn.selected = YES;
    
    NSArray *diceList;

    if (_curSelecetedDiceCountBtn.tag == _start) {
        if (_lastCallDice == 1) {
            diceList = [self genDiceListStartWith:1 end:6];
        }else {
            PBDice_Builder *diceBuilder = [[[PBDice_Builder alloc] init] autorelease];
            [diceBuilder setDice:1];
            [diceBuilder setDiceId:1];
            PBDice *dice = [diceBuilder build];
            NSArray *array1 = [NSArray arrayWithObjects:dice, nil];
            NSArray *array2 = [self genDiceListStartWith:(_lastCallDice + 1) end:6];
            diceList = [array1 arrayByAddingObjectsFromArray:array2];
        }
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

- (NSArray *)genDiceListWithDiceArray:(NSArray *)array
{
    NSMutableArray *dices = [NSMutableArray array];
    
    for (NSNumber *number in array) {
        PBDice_Builder *diceBuilder = [[[PBDice_Builder alloc] init] autorelease];
        [diceBuilder setDice:[number intValue]];
        [diceBuilder setDiceId:[number intValue]];
        PBDice *dice = [diceBuilder build];
        
        [dices addObject:dice];
    }
    
    return dices;
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
    if ([_delegate respondsToSelector:@selector(didSelectDice:count:)]) {
        [_delegate didSelectDice:dice count:_curSelecetedDiceCountBtn.tag];
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

- (void)dismiss
{
    [self.popView dismissAnimated:YES];
}


@end
