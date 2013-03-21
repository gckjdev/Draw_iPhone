//
//  UserDetailProtocol.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@protocol UserDetailProtocol <NSObject>

- (NSString*)getUserId;
- (PBGameUser*)queryUser;
- (BOOL)canEdit;
- (BOOL)needUpdate;
- (BOOL)canFollow;
- (BOOL)canChat;
- (BOOL)canDraw;

 @optional
- (void)setPbGameUser:(PBGameUser*)pbUser;
@end
