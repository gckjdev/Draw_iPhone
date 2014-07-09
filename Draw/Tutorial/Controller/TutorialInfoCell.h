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
@property (retain, nonatomic) IBOutlet UILabel *tutorialSortedLabel;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *tutorialSortedNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDescNameLabel;




- (void)updateCellInfo:(PBTutorial*)pbTutorial;

-(IBAction)clickAddBtn:(id)sender;

@end

