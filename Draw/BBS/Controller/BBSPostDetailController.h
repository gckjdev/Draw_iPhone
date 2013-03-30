//
//  BBSPostDetailController.h
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "BBSController.h"
#import "BBSManager.h"
#import "BBSService.h"
#import "BBSPostActionCell.h"
#import "CreatePostController.h"
#import "BBSPostActionHeaderView.h"
#import "MWPhotoBrowser.h"

@interface BBSPostDetailController : BBSController<BBSPostActionCellDelegate, BBSPostActionHeaderViewDelegate, CreatePostControllerDelegate>
{
    
}

@property (nonatomic, retain)PBBBSPost *post;

+ (BBSPostDetailController *)enterPostDetailControllerWithPost:(PBBBSPost *)post
                                                fromController:(UIViewController *)fromController
                                                      animated:(BOOL)animated;


+ (BBSPostDetailController *)enterPostDetailControllerWithPostID:(NSString *)postID
                                                fromController:(UIViewController *)fromController
                                                      animated:(BOOL)animated;


+ (UIViewController *)enterFreeIngotPostController:(UIViewController *)fromController
                                                 animated:(BOOL)animated;

+ (UIViewController *)enterFeedbackPostController:(UIViewController *)fromController
                                                 animated:(BOOL)animated;

+ (UIViewController *)enterBugReportPostController:(UIViewController *)fromController
                                                 animated:(BOOL)animated;


@end
