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

@class PPTableViewController;


@protocol UserDetailProtocol <NSObject>

- (NSString*)getUserId;
//- (PBGameUser*)queryUser;
- (BOOL)canEdit;
- (BOOL)needUpdate;
- (BOOL)canFollow;
- (BOOL)canChat;
- (BOOL)canDraw;

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
// @optional
//- (void)setPbGameUser:(PBGameUser*)pbUser;

@property (assign, nonatomic) RelationType relation;
@end
