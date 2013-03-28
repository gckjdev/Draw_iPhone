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

typedef void (^LoadFeedFinishBlock)(int resultCode, NSArray* feedList);


@protocol UserDetailProtocol <NSObject>

- (NSString*)getUserId;
//- (PBGameUser*)queryUser;
- (BOOL)canEdit;
- (BOOL)needUpdate;
- (BOOL)canFollow;
- (BOOL)canChat;
- (BOOL)canDraw;
- (BOOL)canBlack;
- (BOOL)canSuperBlack;

- (PBGameUser*)getUser;
- (void)loadUser:(PPTableViewController*)viewController;
- (void)loadFeedByTabAction:(int)tabAction finishBLock:(LoadFeedFinishBlock)block;

// @optional
//- (void)setPbGameUser:(PBGameUser*)pbUser;

@property (assign, nonatomic) RelationType relation;
@end
