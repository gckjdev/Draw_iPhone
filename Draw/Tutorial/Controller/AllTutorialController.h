//
//  AllTutorialController.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"

@class TutorialInfoController;
@class TutorialInfoCell;
@protocol AddButtonDelegate

- (void)clickAddButton:(UIButton*)button;

@end
@interface AllTutorialController : PPTableViewController

@property (retain, nonatomic) TutorialInfoController* infoController;
@end



