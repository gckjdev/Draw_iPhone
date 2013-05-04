//
//  ShowFeedSceneProtocol.h
//  Draw
//
//  Created by Kira on 13-5-3.
//
//

#import <Foundation/Foundation.h>
#import "DrawDataService.h"
#import "PPTableViewController.h"

@protocol ShowFeedSceneProtocol <NSObject>

- (void)initNavitgatorRightBtn:(UIButton*)btn;
- (void)didClickNaviatorRightBtn:(PPTableViewController<DrawDataServiceDelegate>*)controller;
- (void)didClickBackBtn:(PPViewController*)controller;
- (void)initContentImageView:(UIImageView*)view withFeed:(DrawFeed*)feed;
- (NSString*)showFeedTitle;

@end
