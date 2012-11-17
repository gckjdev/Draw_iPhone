//
//  BBSPostListController.h
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "CommonTabController.h"


@class PBBBSPost;
@class PBBBSUser;
@class PBBBSBoard;

@interface BBSPostListController : CommonTabController
{
    
}

//@property (retain, nonatomic)  UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *createPostButton;
@property (retain, nonatomic) IBOutlet UIButton *rankButton;
- (IBAction)clickCreatePostButton:(id)sender;
- (IBAction)clickRankButton:(id)sender;

@end
