//
//  GuessSelectController.h
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "CommonTabController.h"
#import "GuessService.h"
#import "CommonTitleView.h"
#import "DrawGuessController.h"

@interface GuessSelectController : CommonTabController<GuessServiceDelegate, CommonGuessControllerDelegate>

@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

- (id)initWithMode:(PBUserGuessMode)mode contestId:(NSString *)contestId;

@end

