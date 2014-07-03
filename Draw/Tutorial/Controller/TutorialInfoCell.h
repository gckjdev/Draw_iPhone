//
//  TutorialInfoCell.h
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import <UIKit/UIKit.h>
#import "Tutorial.pb.h"

@protocol AddButtonDelegate;

@interface TutorialInfoCell :UITableViewCell<AddButtonDelegate,UIAlertViewDelegate>
{
}

@property (nonatomic, retain) id <AddButtonDelegate> delegate;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDesc;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDescInfo;
@property (retain, nonatomic) IBOutlet UIButton *tutorialAddBtn;

- (void)updateCellInfo:(PBTutorial*)pbTutorial;

-(IBAction)clickAddBtn:(id)sender;

@end


@protocol AddButtonDelegate<NSObject>

-(void)clickButton;

@end