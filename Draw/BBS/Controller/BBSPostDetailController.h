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

@class PBGroup;
@interface BBSPostDetailController : BBSController<BBSPostActionCellDelegate, BBSPostActionHeaderViewDelegate, CreatePostControllerDelegate>
{
    
}

@property (nonatomic, retain)PBBBSPost *post;
@property (nonatomic, retain) UIView* adView;


//@property (nonatomic, retain) PBGroup *group;

- (void)updateViewWithPost:(PBBBSPost *)post;
- (void)updateFooterView;

+ (BBSPostDetailController *)enterPostDetailControllerWithPost:(PBBBSPost *)post
                                                fromController:(UIViewController *)fromController
                                                      animated:(BOOL)animated;

+ (BBSPostDetailController *)enterGroupPostDetailController:(PBBBSPost *)post
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
