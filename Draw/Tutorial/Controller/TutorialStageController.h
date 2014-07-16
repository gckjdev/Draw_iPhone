//
//  TutorialStageController.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import <UIKit/UIKit.h>
#import "Tutorial.pb.h"
#import "PPViewController.h"

@interface TutorialStageController : PPViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;


+ (TutorialStageController*)enter:(PPViewController*)superViewController
                          pbTutorial:(PBUserTutorial*)pbUserTutorial;


@end
