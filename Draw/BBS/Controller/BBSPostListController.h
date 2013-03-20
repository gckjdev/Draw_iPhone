//
//  BBSPostListController.h
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "BBSController.h"
#import "BBSService.h"
#import "BBSPostCell.h"
#import "CreatePostController.h"
#import "MWPhotoBrowser.h"

@class PBBBSPost;
@class PBBBSUser;
@class PBBBSBoard;

@interface BBSPostListController : BBSController<BBSServiceDelegate, BBSPostCellDelegate, MWPhotoBrowserDelegate>
{
    
}

//@property (retain, nonatomic)  UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *createPostButton;
@property (retain, nonatomic) IBOutlet UIButton *rankButton;
@property (retain, nonatomic) PBBBSBoard *bbsBoard;
@property (retain, nonatomic) PBBBSUser *bbsUser;


- (IBAction)clickCreatePostButton:(id)sender;
- (IBAction)clickRankButton:(id)sender;

+ (BBSPostListController *)enterPostListControllerWithBBSBoard:(PBBBSBoard *)board
                                                fromController:(UIViewController *)fromController;

+ (BBSPostListController *)enterPostListControllerWithBBSUser:(PBBBSUser *)bbsUser
                                               fromController:(UIViewController *)fromController;

@end
