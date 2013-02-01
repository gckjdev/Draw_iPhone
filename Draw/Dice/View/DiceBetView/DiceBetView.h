//
//  DiceBetView.h
//  Draw
//
//  Created by 小涛 王 on 12-9-18.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGlossyButton.h"

@protocol DiceBetViewDelegate <NSObject>
        
@required
- (void)didBetOpenUserWin:(BOOL)win
                     ante:(int)ante
                     odds:(float)odds;

@end

@interface DiceBetView : UIView

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *noteLabel;
@property (retain, nonatomic) IBOutlet UILabel *anteLabel;
@property (retain, nonatomic) IBOutlet UILabel *anteCoinsLabel;
@property (retain, nonatomic) IBOutlet UILabel *winLabel;
@property (retain, nonatomic) IBOutlet UILabel *winOddsLabel;
@property (retain, nonatomic) IBOutlet UILabel *loseLabel;
@property (retain, nonatomic) IBOutlet UILabel *loseOddsLabel;
@property (retain, nonatomic) IBOutlet UIGlossyButton *betWinButton;
@property (retain, nonatomic) IBOutlet UIGlossyButton *betLoseButton;

+ (void)showInView:(UIView *)view
          duration:(int)duration
          openUser:(NSString *)nickName
              ante:(int)ante
           winOdds:(float)winOdds
          loseOdds:(float)loseOdds
          delegate:(id<DiceBetViewDelegate>)delegate;


@end
