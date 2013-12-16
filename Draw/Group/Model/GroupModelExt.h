//
//  GroupModelExt.h
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import <Foundation/Foundation.h>
#import "Group.pb.h"

@interface PBGroupNotice(Ext)

- (NSString *)desc;
- (NSString *)msg;
- (NSString *)createDateString;
@end

@interface PBGroup(Ext)

- (NSURL *)medalImageURL;
- (NSURL *)bgImageURL;
- (NSString *)creatorNickName;
- (BOOL)creatorIsMe;

@end


@interface PBGroupUsersByTitle(Ext)

- (BOOL)isCreator;
- (BOOL)isCustomTitle;
- (NSString *)titleName;
- (NSString *)desc;

@end