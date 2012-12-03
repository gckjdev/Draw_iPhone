//
//  BBSActionSheet.h
//  Draw
//
//  Created by gamy on 12-12-3.
//
//

#import <UIKit/UIKit.h>
#import "BBSOptionView.h"



@interface BBSActionSheet : BBSOptionView

- (void)showInView:(UIView *)view showAtPoint:(CGPoint )point animated:(BOOL)animated;

@end
