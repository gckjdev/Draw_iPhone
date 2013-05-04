//
//  FeedSceneDetailGuessResult.m
//  Draw
//
//  Created by Kira on 13-5-4.
//
//

#import "FeedSceneDetailGuessResult.h"
#import "HomeController.h"

#define LABEL_TAG 20130504

@implementation FeedSceneDetailGuessResult

- (void)initNavitgatorRightBtn:(UIButton*)btn
{
    //do nothing
}
- (void)didClickNaviatorRightBtn:(PPTableViewController<DrawDataServiceDelegate>*)controller
{
    [controller reloadTableViewDataSource];
}

- (void)didClickBackBtn:(PPViewController*)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}
#define LABEL_HEIGHT (ISIPAD?40:20)
- (void)initContentImageView:(UIImageView*)view withFeed:(DrawFeed*)feed
{
    UILabel* label = (UILabel*)[view viewWithTag:LABEL_TAG];
    if (label == nil) {
//        PPDebug(@"image size = %.2f, %.2f, view size = %.2f, %.2f",view.image.size.width, view.image.size.height, view.frame.size.width, view.frame.size.height);
        float width = view.frame.size.height*view.image.size.width/view.image.size.height;
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, (view.frame.size.height-LABEL_HEIGHT), width, LABEL_HEIGHT)] autorelease];
        [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setCenter:CGPointMake(view.frame.size.width/2, label.center.y)];
        label.tag = LABEL_TAG;
        
        [view addSubview:label];
    }
    [label setText:feed.wordText];
//    PPDebug(@"view frame = (x, x, %.2f, %.2f)", view.frame.size.width, view.frame.size.height);
//    PPDebug(@"label frame = (%.2f, %.2f, %.2f, %.2f)",label.frame.origin.x, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
    
    
}

- (NSString*)showFeedTitle
{
    return NSLS(@"kGuessResult");
}

@end
