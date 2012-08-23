//
//  MenuPanel.m
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuPanel.h"

@implementation MenuPanel
@synthesize versionLabel = _versionLabel;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize controller = _controller;

- (MenuPanel *)menuPanelWithController:(UIViewController *)controller
{
    static NSString *identifier = @"MenuPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    MenuPanel *panel = [topLevelObjects objectAtIndex:0];
    panel.controller = controller;
    [panel loadMenu];
    return  panel;
}


#pragma mark load menu
- (void)loadMenu
{
    
}


#pragma mark resource for button

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

