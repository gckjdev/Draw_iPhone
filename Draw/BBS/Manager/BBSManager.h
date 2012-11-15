//
//  BBSManager.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import <Foundation/Foundation.h>
//#import "Game.p"
//#import "GameMessage.pb.h"
//#import "GameBasic.pb.h"
#import "Bbs.pb.h"
@interface BBSManager : NSObject

+(void)printBBSBoard:(PBBBSBoard *)board;
+(void)printBBSContent:(PBBBSContent *)content;
+(void)printBBSUser:(PBBBSUser *)user;
+(void)printBBSPost:(PBBBSPost *)post;
+(void)printBBSAction:(PBBBSAction *)action;

@end
