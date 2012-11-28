//
//  PPViewController+StarryLoadingView.h
//  Draw
//
//  Created by Kira on 12-11-27.
//
//

#import "PPViewController.h"

@interface PPViewController (StarryLoadingView)

- (void)showStarryLoadingWithText:(NSString*)loadingText withCenter:(CGPoint)point;
- (void)showStarryLoadingWithText:(NSString*)loadingText;
- (void)showStarryLoading;
- (void)hideStarryLoading;

@end
