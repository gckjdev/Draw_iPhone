//
//  GuessRankListController.h
//  Draw
//
//  Created by 王 小涛 on 13-7-24.
//
//

#import "PPViewController.h"
#import "CommonTabController.h"
#import "GuessService.h"

@interface GuessRankListController : CommonTabController <GusessServiceDelegate>
@property (retain, nonatomic) IBOutlet UIButton *geniusButton;
@property (retain, nonatomic) IBOutlet UIButton *contestButton;


@end
