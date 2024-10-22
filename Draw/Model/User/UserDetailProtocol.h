//
//  UserDetailProtocol.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"
#import "MyFriend.h"
#import "ChangeAvatar.h"


@class UserDetailRoundButton;
@class PPTableViewController;


@protocol UserDetailProtocol <NSObject>

- (NSString*)getUserId;
- (BOOL)canEdit;
- (BOOL)shouldShow;
- (BOOL)isBlackBtnVisable;
- (BOOL)isSuperManageBtnVisable;
- (BOOL)hasFeedTab;

- (BOOL)isPrivacyVisable;

- (PBGameUser*)getUser;
- (void)loadUser:(PPTableViewController*)viewController;

- (void)blackUser:(PPTableViewController*)viewController;
- (void)superManageUser:(PPTableViewController*)viewController;
- (void)clickSNSBtnType:(int)snsType
         viewController:(PPTableViewController*)viewController;
- (void)viewBBSPost:(PPViewController*)controller;

- (NSString*)blackUserBtnTitle;

- (void)initSNSButton:(UIButton*)button
             withType:(int)snsType;

- (void)initUserActionButton:(UserDetailRoundButton*)button atIndex:(int)index;
- (void)clickUserActionButtonAtIndex:(int)index viewController:(PPTableViewController*)viewController;
// @optional
//- (void)setPbGameUser:(PBGameUser*)pbUser;

- (void)clickAvatar:(PPTableViewController<ChangeAvatarDelegate>*)viewController
     didSelectBlock:(void(^)(UIImage* image))aBlock;
- (void)clickCustomBg:(PPTableViewController <ChangeAvatarDelegate>*)viewController didSelectBlock:(void (^)(UIImage *))aBlock;
@property (assign, nonatomic) RelationType relation;
@end
