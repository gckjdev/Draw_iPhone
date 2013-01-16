//
//  BBSActionListController.h
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "CommonTabController.h"
#import "BBSService.h"
#import "BBSActionSheet.h"
#import "MWPhotoBrowser.h"

@interface BBSActionListController : CommonTabController<BBSServiceDelegate, BBSOptionViewDelegate,MWPhotoBrowserDelegate>
{
    
}


+ (BBSActionListController *)enterActionListControllerFromController:(UIViewController *)fromController animated:(BOOL)animated;

@end
