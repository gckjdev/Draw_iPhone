//
//  FeedSceneGuessResult.m
//  Draw
//
//  Created by Kira on 13-5-3.
//
//

#import "FeedSceneGuessResult.h"
#import "HomeController.h"
#import "Draw.h"

#define LABEL_TAG 20130504

@implementation FeedSceneGuessResult

- (void)initNavitgatorRightBtn:(UIButton*)btn
{
    [btn setImage:nil forState:UIControlStateNormal];
    [btn setTitle:NSLS(@"kOneMore") forState:UIControlStateNormal];
}
- (void)didClickNaviatorRightBtn:(PPTableViewController<DrawDataServiceDelegate>*)controller
{
    [controller showActivityWithText:NSLS(@"kLoading")];
    [[DrawDataService defaultService] matchDraw:controller];
}
- (void)didClickBackBtn:(PPViewController*)controller
{
    [HomeController returnRoom:controller];
}
#define LABEL_HEIGHT (ISIPAD?40:20)
- (void)initContentImageView:(UIImageView*)view withFeed:(DrawFeed*)feed
{
    UILabel* label = (UILabel*)[view viewWithTag:LABEL_TAG];
    if (label == nil) {
        float width = view.frame.size.height*view.image.size.width/view.image.size.height;
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height-LABEL_HEIGHT, width, LABEL_HEIGHT)] autorelease];
        [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setCenter:CGPointMake(view.frame.size.width/2, label.center.y)];
        label.tag = LABEL_TAG;
        [label setText:feed.drawData.word.text];
        [view addSubview:label];
    }
    
    
    
}

- (NSString*)showFeedTitle
{
    return NSLS(@"kGuessResult");
}
@end
