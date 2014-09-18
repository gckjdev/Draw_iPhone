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
#import "FeedService.h"
#import "StableView.h"

@class TutorialInfoController;

@interface TutorialStageController : PPViewController<UICollectionViewDataSource,UICollectionViewDelegate,FeedServiceDelegate,AvatarViewDelegate>

@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain, nonatomic) TutorialInfoController* infoController;

+ (TutorialStageController*)enter:(PPViewController*)superViewController
                          pbTutorial:(PBUserTutorial*)pbUserTutorial;


@end
