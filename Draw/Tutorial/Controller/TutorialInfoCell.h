//
//  TutorialInfoCell.h
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import <UIKit/UIKit.h>
@protocol AddButtonDelegate;
@interface TutorialInfoCell :UITableViewCell<AddButtonDelegate,UIAlertViewDelegate>{
    id <AddButtonDelegate> delegate;
}
@property (nonatomic, retain) id <AddButtonDelegate> delegate;

@property (retain, nonatomic) IBOutlet UILabel *tutorialDesc;

@property (retain, nonatomic) IBOutlet UILabel *tutorialDescInfo;
@property (retain, nonatomic) IBOutlet UIButton *tutorialAddBtn;

-(IBAction)clickAddBtn:(id)sender;
@end


@protocol AddButtonDelegate<NSObject>

-(void)clickButton;

@end