//
//  GuessRankListController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-24.
//
//

#import "GuessRankListController.h"
#import "GuessService.h"

@interface GuessRankListController ()

@end

@implementation GuessRankListController

- (void)dealloc{
    
    [[GuessService defaultService] setDelegate:nil];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[GuessService defaultService] getGuessRankListWithType:HOT_RANK mode:PBUserGuessModeGuessModeHappy contestId:nil offset:0 limit:20];
    [[GuessService defaultService] setDelegate:self];
    
}

- (void)didGetGuessRankList:(NSArray *)list resultCode:(int)resultCode;


@end
