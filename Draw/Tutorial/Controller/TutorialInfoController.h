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

@property(nonatomic,retain) NSArray *sectionTitle;
@property(nonatomic,retain) NSArray *numberRowsSection;

+ (TutorialInfoController*)enter:(PPViewController*)superViewController
                      pbTutorial:(PBTutorial*)pbTutorial;

@end



