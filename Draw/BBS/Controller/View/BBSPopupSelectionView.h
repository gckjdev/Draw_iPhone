//
//  BBSPopupSelectionView.h
//  Draw
//
//  Created by gamy on 12-11-30.
//
//

#import <UIKit/UIKit.h>
#import "BBSOptionView.h"

@interface BBSPopupSelectionView : BBSOptionView

- (void)showInView:(UIView *)view showAbovePoint:(CGPoint )point animated:(BOOL)animated;
@end
