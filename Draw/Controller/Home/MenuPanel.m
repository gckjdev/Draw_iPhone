//
//  MenuPanel.m
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuPanel.h"
#import "MenuButton.h"

@implementation MenuPanel
@synthesize versionLabel = _versionLabel;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize controller = _controller;

+ (MenuPanel *)menuPanelWithController:(UIViewController *)controller
{
    static NSString *identifier = @"MenuPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    MenuPanel *panel = [topLevelObjects objectAtIndex:0];
    panel.controller = controller;
    panel.scrollView.delegate = panel;
    [panel loadMenu];
    return  panel;
}


#pragma mark load menu

#define MENU_PANEL_WIDTH ([DeviceDetection isIPAD] ? 768 : 320)
#define MENU_PANEL_HEIGHT ([DeviceDetection isIPAD] ? 467 : 224)
static const NSInteger MENU_NUMBER_PER_PAGE = 6;

- (CGRect)frameForMenuIndex:(NSInteger)index
{

    static const NSInteger ROW_NUMBER = 3;
    CGFloat xStart = [DeviceDetection isIPAD] ? 32 : 15;
    CGFloat yStart = [DeviceDetection isIPAD] ? 30 : 22;
    int page = index / MENU_NUMBER_PER_PAGE;   
    
    NSInteger row = (index % MENU_NUMBER_PER_PAGE) / ROW_NUMBER;
    NSInteger numberInRow = index % ROW_NUMBER;
    
    CGFloat xSpace = ((MENU_PANEL_WIDTH - 2 *xStart) - ROW_NUMBER * MENU_BUTTON_WIDTH)/ (ROW_NUMBER - 1);
    CGFloat ySpace = (MENU_PANEL_HEIGHT - 2 *yStart - 2 * MENU_BUTTON_HEIGHT);

    CGFloat y = row * (ySpace + MENU_BUTTON_HEIGHT) + yStart;
    CGFloat x = page * self.frame.size.width;
    x += numberInRow *(xSpace + MENU_BUTTON_WIDTH) + xStart;
    
    return CGRectMake(x, y, MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT);
}

- (void)loadMenu
{
    int number = 0;
    for (int i = MenuButtonTypeBase; i < MenuButtonTypeCount; ++ i, ++ number) {
        MenuButton *menu = [MenuButton menuButtonWithType:i];
        menu.frame = [self frameForMenuIndex:number];
        [self.scrollView addSubview:menu];
        [menu setBadgeNumber:number];
    }
    for (int i = MenuButtonTypeBase; i < MenuButtonTypeCount; ++ i, ++ number) {
        MenuButton *menu = [MenuButton menuButtonWithType:i];
        menu.frame = [self frameForMenuIndex:number];
        [self.scrollView addSubview:menu];
        [menu setBadgeNumber:number];
    }
    [self.scrollView setContentSize:CGSizeMake((number / MENU_NUMBER_PER_PAGE)  * MENU_PANEL_WIDTH, MENU_PANEL_HEIGHT)];

}




#pragma mark scrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
        PPDebug(@"<BoardPanel>scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    PPDebug(@"scrollViewDidEndDecelerating, page = %d", self.pageControl.currentPage);    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    PPDebug(@"<BoardPanel>scrollViewDidEndScrollingAnimation");
}


#pragma mark page control
- (IBAction)changePage:(id)sender {
    
}


- (void)dealloc
{
    PPRelease(_versionLabel);
    PPRelease(_scrollView);
    PPRelease(_pageControl);
    PPRelease(_controller);
    [super dealloc];
}
@end

