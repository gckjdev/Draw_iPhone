//
//  BBSPostDetailController.h
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "CommonTabController.h"
#import "BBSManager.h"
#import "BBSService.h"

@interface BBSPostDetailController : CommonTabController<BBSServiceDelegate>
{
    
}


+ (BBSPostDetailController *)enterPostDetailControllerWithPost:(PBBBSPost *)post
                                                fromController:(UIViewController *)fromController
                                                      animated:(BOOL)animated;
@end
