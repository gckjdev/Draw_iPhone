//
//  BBSActionListController.h
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "CommonTabController.h"
#import "BBSService.h"

@interface BBSActionListController : CommonTabController<BBSServiceDelegate>
{
    
}


+ (BBSActionListController *)enterActionListControllerFromController:(UIViewController *)fromController animated:(BOOL)animated;

@end
