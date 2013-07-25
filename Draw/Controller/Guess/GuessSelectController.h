//
//  GuessSelectController.h
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "PPViewController.h"
#import "GuessService.h"

@interface GuessSelectController : PPViewController<GusessServiceDelegate>

@property (retain, nonatomic) IBOutlet UIView *opusesHolderView;
@property (retain, nonatomic) IBOutlet UILabel *guessedInfoLabel;
@property (retain, nonatomic) IBOutlet UILabel *awardInfoLabel;
@property (retain, nonatomic) IBOutlet UILabel *aheadInfoLabel;

- (id)initWithMode:(PBUserGuessMode)mode;

@end

