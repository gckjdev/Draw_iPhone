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


@class UserDetailRoundButton;
@class PPTableViewController;


@protocol UserDetailProtocol <NSObject>

- (NSString*)getUserId;
//- (PBGameUser*)queryUser;
- (BOOL)canEdit;

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

- (NSString*)blackUserBtnTitle;

- (void)initSNSButton:(UIButton*)button
             withType:(int)snsType;

- (void)initUserActionButton:(UserDetailRoundButton*)button atIndex:(int)index;
- (void)clickUserActionButtonAtIndex:(int)index viewController:(PPTableViewController*)viewController;
// @optional
//- (void)setPbGameUser:(PBGameUser*)pbUser;

- (void)clickAvatar:(PPTableViewController*)viewController
     didSelectBlock:(void(^)(UIImage* image))aBlock;

- (void)clickBackground:(PPTableViewController*)viewController
     didSelectBlock:(void(^)(UIImage* image))aBlock;

@property (assign, nonatomic) RelationType relation;
@end
