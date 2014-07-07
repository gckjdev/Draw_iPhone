//
//  TutorialInfoCell.h
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import <UIKit/UIKit.h>
#import "Tutorial.pb.h"


@interface TutorialInfoCell :UITableViewCell<UIAlertViewDelegate>
{
}

@property (retain, nonatomic) IBOutlet UILabel *tutorialDesc;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDescInfo;
@property (retain, nonatomic) IBOutlet UIButton *tutorialAddBtn;

- (void)updateCellInfo:(PBTutorial*)pbTutorial;

-(IBAction)clickAddBtn:(id)sender;

@end

