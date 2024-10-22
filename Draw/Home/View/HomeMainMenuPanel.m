//
//  HomeMainMenuView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeMainMenuPanel.h"
#import "HomeMenuView.h"
#import "MobClickUtils.h"

@interface HomeMainMenuPanel ()
{
//    NSInteger _pageCount;
    NSInteger _menuCount;
}


- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type;


@end

@implementation HomeMainMenuPanel

+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    HomeMainMenuPanel<HomeCommonViewProtocol> *view = [self createViewWithXibIdentifier:[self getViewIdentifier]];
    view.delegate = delegate;
    
    if (ISIPAD){
        [view.next setImage:[UIImage imageNamedFixed:@"common_home_nextpage.png"] forState:UIControlStateNormal];
        
        [view.previous setImage:[UIImage imageNamedFixed:@"common_home_front_page.png"] forState:UIControlStateNormal];
        
    }
    
    [view updateView];
    return view;
}

+ (NSString *)getViewIdentifier
{
    if ([DeviceDetection isIPhone5]) {
//        return @"HomeMainMenuPanel_ip5";
    }
    return @"HomeMainMenuPanel";
}

#define PER_ROW_NUMBER 3
#define PER_LINE_NUMBER 2
#define PER_PAGE_NUMBER (PER_ROW_NUMBER * PER_LINE_NUMBER)

#define SCROLLVIEW_WIDTH (self.scrollView.frame.size.width)
#define SCROLLVIEW_HEIGHT (self.scrollView.frame.size.height)

- (HomeMenuView *)viewWithType:(HomeMenuType)type
                          page:(NSInteger)page
                         index:(NSInteger)index
{
    HomeMenuView *view = [HomeMenuView menuViewWithType:type badge:0 delegate:self];
    CGFloat x = page * SCROLLVIEW_WIDTH;
    NSInteger row = index % PER_ROW_NUMBER;
    CGFloat viewWidth = view.frame.size.width;
    x += viewWidth * row;
    CGFloat y = 0;
    
    NSInteger line = index / PER_ROW_NUMBER;
    if (line > 0) {
        CGFloat viewHeight = view.frame.size.height;
        y += viewHeight;
    }

    CGRect frame = view.frame;
    frame.origin = CGPointMake(x, y);
    view.frame = frame;
    
    return view;
}

- (void)updateView
{
    int *list = getMainMenuTypeList();

    _pageCount = 0;
    _menuCount = 0;
    NSInteger index = 0;
//    PPDebug(@"TypeList = (");
    while(list != NULL && (*list) != HomeMenuTypeEnd) {
        HomeMenuType type = *list;
//        PPDebug(@"%d,",type);
        HomeMenuView *view = [self viewWithType:type page:_pageCount index:index];
        [self.scrollView addSubview:view];
        
        list++;

        if ((++_menuCount) % PER_PAGE_NUMBER == 0) {
            _pageCount = _menuCount / PER_PAGE_NUMBER;
            index = 0;
        }else{
            index ++;
        }
    }
//    PPDebug(@");");
    _pageCount = _menuCount / PER_PAGE_NUMBER;
    if (_menuCount % PER_PAGE_NUMBER != 0) {
        _pageCount++;
    }

    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(width * _pageCount, height);
    self.scrollView.delegate = self;

    [self updatePageButton];
    [self performSelector:@selector(animatePageButtons) withObject:nil afterDelay:1];
    if (isDrawApp() || isSingApp()) {
        [[self viewWithTag:1234] removeFromSuperview];
    }
    
    if (isSingApp()) {
        [[self viewWithTag:101] removeFromSuperview];
    }
}

- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type
{
    for (HomeMenuView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[HomeMenuView class]] && view.type == type) {
            return view;
        }
    }
    return nil;
}

- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge
{
    HomeMenuView *view = [self getMenuViewWithType:type];
    [view updateBadge:badge];
}

- (void)dealloc {
    [_scrollView release];
    [_previous release];
    [_next release];
    [super dealloc];
}

#pragma mark Page methods

- (NSInteger)currentPage
{
    CGFloat x = self.scrollView.contentOffset.x;
    return  x / SCROLLVIEW_WIDTH;
}

- (NSInteger)pageCount
{
    return _pageCount;
}

- (BOOL)isFirstPage
{
    return [self currentPage] == 0;
}

- (BOOL)isLastPage
{
    return [self currentPage] >= ([self pageCount] - 1);
}


#define AMPLITUDE [DeviceDetection isIPAD] ? 50 : 25
#define SPACE_PAGE_EDAGE ([DeviceDetection isIPAD] ? 24 : 12)

- (void)animatePageButtons
{

    CGPoint center = self.next.center;
    center.x = CGRectGetWidth(self.bounds) - SPACE_PAGE_EDAGE;
    self.next.center = center;

    
    
    center.x = SPACE_PAGE_EDAGE;
    self.previous.center = center;
    
    [UIView beginAnimations:@"Animated" context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    center = self.previous.center;
    center.x += AMPLITUDE;
    self.previous.center = center;
    
    center = self.next.center;
    center.x -= AMPLITUDE;
    self.next.center = center;
    
    [UIView commitAnimations];
}

- (void)updatePageButton
{
    [self.previous setHidden:[self isFirstPage]];
    [self.next setHidden:[self isLastPage]];
}

- (void)hidePageButtons
{
    self.next.hidden = self.previous.hidden = YES;
}
- (void)scrollToPage:(NSInteger)page
{
    if (page >= 0 && page < [self pageCount]) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = page * SCROLLVIEW_WIDTH;
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (void)previousPage
{
    if (![self isFirstPage]) {
        [self scrollToPage:([self currentPage] - 1)];
    }
}
- (void)nextPage
{
    if (![self isLastPage]) {
        [self scrollToPage:([self currentPage] + 1)];
    }
}
- (IBAction)clickPageButton:(id)sender {
    if (sender == self.previous) {
        [self previousPage];
    }else if (sender == self.next){
        [self nextPage];
    }
}

- (HomeMenuType)getMainType
{
    if (isDrawApp()) {
        return HomeMenuTypeDrawDraw;
    }else if(isSingApp()){
        return HomeMenuTypeSing;
    }
    return HomeMenuTypeDrawDraw;
}

#pragma mark - Scroll View delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePageButton];    
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updatePageButton];
}


#pragma mark - Home Menu View Delegate

- (void)didClickMenu:(HomeMenuView *)menu type:(HomeMenuType)type
{
    [MobClick event:@"CLICK_MENU_BUTTON"
              label:[HomeMenuView titleForType:type]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeMainMenuPanel:didClickMenu:menuType:)]) {
        [self.delegate homeMainMenuPanel:self didClickMenu:menu menuType:type];
    }
}
@end
