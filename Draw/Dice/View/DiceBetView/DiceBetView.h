//
//  DiceBetView.h
//  Draw
//
//  Created by 小涛 王 on 12-9-18.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKGirlFontLabel.h"

@protocol DiceBetViewDelegate <NSObject>
        
@required
- (void)didBetOpenUserWin:(BOOL)win
                     ante:(int)ante
                     odds:(float)odds;

@end

@interface DiceBetView : UIView

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *titleLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *noteLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *anteLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *anteCoinsLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *winLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *winOddsLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *loseLabel;
@property (retain, nonatomic) IBOutlet HKGirlFontLabel *loseOddsLabel;
@property (retain, nonatomic) IBOutlet UIButton *betWinButton;
@property (retain, nonatomic) IBOutlet UIButton *betLoseButton;

+ (void)showInView:(UIView *)view
          duration:(int)duration
          openUser:(NSString *)nickName
              ante:(int)ante
           winOdds:(float)windOdds
          loseOdds:(float)loseOdds
          delegate:(id<DiceBetViewDelegate>)delegate;


@end
