//
//  AllTutorialCell.h
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import <UIKit/UIKit.h>

@class PBTutorial;

@interface AllTutorialCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *tutorialName;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDesc;
@property (retain, nonatomic) IBOutlet UIImageView *tutorialImage;

- (void)updateCellInfo:(PBTutorial*)pbTutorial;

@end
