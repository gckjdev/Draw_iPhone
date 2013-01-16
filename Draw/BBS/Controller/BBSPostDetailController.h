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
#import "BBSPostActionCell.h"
#import "CreatePostController.h"
#import "BBSPostActionHeaderView.h"
#import "MWPhotoBrowser.h"

@interface BBSPostDetailController : CommonTabController<BBSServiceDelegate, BBSPostActionCellDelegate, CreatePostControllerDelegate, BBSPostActionHeaderViewDelegate, MWPhotoBrowserDelegate>
{
    
}

@property (nonatomic, retain)PBBBSPost *post;

+ (BBSPostDetailController *)enterPostDetailControllerWithPost:(PBBBSPost *)post
                                                fromController:(UIViewController *)fromController
                                                      animated:(BOOL)animated;
- (IBAction)clickSupportButton:(id)sender;
- (IBAction)clickReplyButton:(id)sender;

@end
