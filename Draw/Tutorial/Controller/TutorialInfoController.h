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
@interface TutorialInfoController : PPTableViewController<AddButtonDelegate>

@property(nonatomic,retain) NSArray *sectionTitle;
@property(nonatomic,retain) NSArray *numberRowsSection;

@end



