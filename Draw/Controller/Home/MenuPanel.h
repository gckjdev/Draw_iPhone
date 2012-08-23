//
//  MenuPanel.h
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuPanel : UIView<UIScrollViewDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) UIViewController *controller;

+ (MenuPanel *)menuPanelWithController:(UIViewController *)controller;
- (IBAction)changePage:(id)sender;
- (void)loadMenu;

@end
