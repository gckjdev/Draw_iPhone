//
//  BBSActionListController.h
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

//#import "CommonTabController.h"
#import "BBSController.h"
#import "BBSService.h"
#import "BBSActionSheet.h"
#import "MWPhotoBrowser.h"

@class PBBBSAction;

@interface BBSActionListController : BBSController<BBSOptionViewDelegate>
{
    
}


+ (BBSActionListController *)enterActionListControllerFromController:(UIViewController *)fromController animated:(BOOL)animated;
+ (void)showReplyActions:(UIViewController*)superController postId:(NSString*)postId postUserId:(NSString*)postUserId sourceAction:(PBBBSAction*)sourceAction;

@end
