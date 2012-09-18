//
//  DiceBetView.h
//  Draw
//
//  Created by 小涛 王 on 12-9-18.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKGirlFontLabel.h"

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
@end
