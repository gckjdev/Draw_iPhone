//
//  PPViewController+StarryLoadingView.m
//  Draw
//
//  Created by Kira on 12-11-27.
//
//

#import "PPViewController+StarryLoadingView.h"
#import "StarryLoadingView.h"

#define STARRY_LOADING_VIEW_TAG 20121127

@implementation PPViewController (StarryLoadingView)

- (StarryLoadingView*)getStarryLoadingViewWithText:(NSString*)loadingText withCenter:(CGPoint)point
{
    StarryLoadingView* starryLoadingView = (StarryLoadingView*)[self.view viewWithTag:STARRY_LOADING_VIEW_TAG];
    if (starryLoadingView == nil){
		starryLoadingView = [[[StarryLoadingView alloc] initWithTitle:@"" message:loadingText] autorelease];
        starryLoadingView.tag = STARRY_LOADING_VIEW_TAG;
        starryLoadingView.loadingView.center = point;
		[starryLoadingView showInView:self.view];
	}
	
	return starryLoadingView;
}

- (StarryLoadingView*)getStarryLoadingViewWithText:(NSString*)loadingText
{
    StarryLoadingView* starryLoadingView = (StarryLoadingView*)[self.view viewWithTag:STARRY_LOADING_VIEW_TAG];
	if (starryLoadingView == nil){
		starryLoadingView = [[[StarryLoadingView alloc] initWithTitle:@"" message:loadingText] autorelease];
        //        PPDebug(@"text = %@", loadingText);
        //        PPDebug(@"view center = (%f, %f)", self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        starryLoadingView.tag = STARRY_LOADING_VIEW_TAG;
        if ([DeviceDetection isIPAD]) {
            starryLoadingView.loadingView.center = CGPointMake(384, 522);
        } else {
            starryLoadingView.loadingView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2+10);
        }
        
		[starryLoadingView showInView:self.view];
	}
	
	return starryLoadingView;
}

- (void)showStarryLoadingWithText:(NSString*)loadingText withCenter:(CGPoint)point
{
    StarryLoadingView* starryLoadingView = [self getStarryLoadingViewWithText:loadingText withCenter:point];
	[starryLoadingView setMessage:loadingText];
	[starryLoadingView startAnimating];
	starryLoadingView.hidden = NO;
}

- (void)showStarryLoadingWithText:(NSString*)loadingText
{
	StarryLoadingView* starryLoadingView = [self getStarryLoadingViewWithText:loadingText];
	[starryLoadingView setMessage:loadingText];
	[starryLoadingView startAnimating];
	starryLoadingView.hidden = NO;
    [self.view bringSubviewToFront:starryLoadingView];
}

- (void)showStarryLoading
{
    [self showActivityWithText:@""];
}

- (void)hideStarryLoading
{
    StarryLoadingView* starryLoadingView = (StarryLoadingView*)[self.view viewWithTag:STARRY_LOADING_VIEW_TAG];
    if (starryLoadingView && [starryLoadingView respondsToSelector:@selector(stopAnimating)]) {
        [starryLoadingView stopAnimating];
        starryLoadingView.hidden = YES;
    }
}

@end
