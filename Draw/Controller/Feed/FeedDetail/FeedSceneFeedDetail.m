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

}

- (NSString*)showFeedTitle{
    return nil;
}

@end
