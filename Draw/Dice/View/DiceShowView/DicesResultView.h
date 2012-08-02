//
//  DicesResultView.h
//  Draw
//
//  Created by haodong on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"

@interface DicesResultView : UIView

@property (retain, nonatomic) NSString *userId;

+ (DicesResultView *)createDicesResultView;
- (void)setDices:(PBUserDice *)userDice;

@end
