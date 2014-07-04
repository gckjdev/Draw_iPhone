//
//  StageCell.h
//  Draw
//
//  Created by ChaoSo on 14-7-2.
//
//

#import <UIKit/UIKit.h>
#import "Tutorial.pb.h"


@class PBUserTutorial;
@interface StageCell : UICollectionViewCell
@property (retain, nonatomic) IBOutlet UIImageView *stageCellImage;
@property (retain, nonatomic) IBOutlet UILabel *cellName;

-(void)updateStageCellInfo:(PBUserTutorial *)pbUserTutorial withRow:(NSInteger)row;
@property (retain, nonatomic) IBOutlet UIButton *stageListStarBtn;

@end
