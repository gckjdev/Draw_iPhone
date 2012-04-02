//
//  StableView.h
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolView : UIButton
{
    NSInteger _number;
    UIButton *numberButton;
}
- (id)initWithNumber:(NSInteger)number;
- (void)setNumber:(NSInteger)number;
- (NSInteger)number;
- (void)addTarget:(id)target action:(SEL)action;
- (void)decreaseNumber;
@end
