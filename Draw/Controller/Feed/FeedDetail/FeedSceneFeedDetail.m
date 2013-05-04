//
//  FeedSceneFeedDetail.m
//  Draw
//
//  Created by Kira on 13-5-3.
//
//

#import "FeedSceneFeedDetail.h"

@implementation FeedSceneFeedDetail

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
//#define LABEL_HEIGHT ISIPAD?40:20
- (void)initContentImageView:(UIImageView*)view withFeed:(DrawFeed*)feed
{
//    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height-LABEL_HEIGHT, view.frame.size.width, LABEL_HEIGHT)] autorelease];
//    [label setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
//    [label setTextColor:[UIColor whiteColor]];
//    [label setText:wordText];
//    
//    [view addSubview:label];
    //do nothing
    
}

- (NSString*)showFeedTitle{
    return nil;
}

@end
