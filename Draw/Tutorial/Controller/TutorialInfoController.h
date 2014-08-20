//
//  TutorialInfoController.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "TutorialInfoCell.h"
#import "Tutorial.pb.h"
#import "AllTutorialController.h"

@interface TutorialInfoController : PPTableViewController
@property CGFloat tutorialCellInfoHeight;
@property(nonatomic,retain) NSArray *sectionTitle;
@property(nonatomic,retain) NSArray *numberRowsSection;
@property BOOL unable;

+ (TutorialInfoController *)show:(PPViewController*)superController
                        tutorial:(PBTutorial*)pbTutorial
                        infoOnly:(BOOL)infoOnly;

+(TutorialInfoController *)createController:(PBTutorial*)pbTutorial
                                   infoOnly:(BOOL)infoOnly;
@end



