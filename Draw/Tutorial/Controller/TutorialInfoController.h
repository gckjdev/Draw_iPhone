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

@interface TutorialInfoController : PPTableViewController
@property CGFloat tutorialCellInfoHeight;
@property(nonatomic,retain) NSArray *sectionTitle;
@property(nonatomic,retain) NSArray *numberRowsSection;
@property BOOL unable;

+ (TutorialInfoController*)enter:(PPViewController*)superViewController
                      pbTutorial:(PBTutorial*)pbTutorial infoOnly:(BOOL)infoOnly;

@end



