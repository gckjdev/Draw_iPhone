//
//  SuperHomeController.h
//  Draw
//
//  Created by qqn_pipi on 12-10-6.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "HomeHeaderPanel.h"
#import "HomeMainMenuPanel.h"
#import "HomeBottomMenuPanel.h"

@interface SuperHomeController : PPViewController<HomeCommonViewDelegate>
{
    
}

@property(nonatomic, retain)HomeHeaderPanel *headerPanel;
@property(nonatomic, retain)HomeMainMenuPanel *mainMenuPanel;
@property(nonatomic, retain)HomeBottomMenuPanel *bottomMenuPanel;

@end
