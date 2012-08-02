//
//  DicesResultView.h
//  Draw
//
//  Created by haodong on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DicesResultView : UIView

+ (DicesResultView *)createDicesResultView;
- (void)setDices:(NSArray *)dices;

@end
