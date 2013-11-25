//
//  BBSController.h
//  Draw
//
//  Created by gamy on 13-3-20.
//
//

#import "CommonTabController.h"
#import "BBSService.h"
#import "BBSPostActionCell.h"

@interface BBSController : CommonTabController<BBSServiceDelegate>
@property (nonatomic, assign) BOOL forGroup;

- (BBSService *)bbsService;

@end
