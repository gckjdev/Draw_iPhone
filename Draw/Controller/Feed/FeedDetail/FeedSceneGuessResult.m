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
#import "ShareImageManager.h"
#import "UIColor+UIColorExt.h"

#define LABEL_TAG 20130504

@implementation FeedSceneGuessResult

- (void)initNavitgatorRightBtn:(UIButton*)btn
{
    [btn setImage:nil forState:UIControlStateNormal];
    [btn setTitle:NSLS(@"kGoOnGuess") forState:UIControlStateNormal];
    [btn setBackgroundImage:[[ShareImageManager defaultManager] navigatorRightBtnImage] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(btn.frame.origin.x - btn.frame.size.width, btn.frame.origin.y, btn.frame.size.width*2, btn.frame.size.height)];
    [btn setTitleColor:COLOR_COFFEE forState:UIControlStateNormal];
    
}
- (void)didClickNaviatorRightBtn:(PPTableViewController<DrawDataServiceDelegate>*)controller
{
    [controller showActivityWithText:NSLS(@"kLoading")];
    [[DrawDataService defaultService] matchDraw:controller];
}
- (void)didClickBackBtn:(PPViewController*)controller
{
    [controller.navigationController popToViewController:[HomeController defaultInstance] animated:YES];
}
#define LABEL_HEIGHT (ISIPAD?40:20)
#define LABEL_FONT_SIZE  (ISIPAD?30:15)
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
        [label setFont:[UIFont systemFontOfSize:LABEL_FONT_SIZE]];
        [view addSubview:label];
    }
    
    
    
}

- (NSString*)showFeedTitle
{
    return NSLS(@"kGuessResult");
}
@end
