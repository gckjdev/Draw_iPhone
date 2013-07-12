//
//  OpusActionManager.h
//  Draw
//
//  Created by 王 小涛 on 13-7-4.
//
//

#import <Foundation/Foundation.h>

enum{
    ActionShareViaSinaWeiBo = 100,
    ActionShareViaTencentWeiBo = 101,
    ActionShareViaFacebook = 102,
    ActionShareViaWeChatTimeline = 103,
    ActionShareViaWeChatFriends = 104,
    ActionShareViaEmail = 105,
    ActionSaveToAlbum = 106,
    ActionSaveAsFavorite = 107
};

@interface OpusActionManager : NSObject

+ (NSString *)nameWithAction:(int)action;
+ (UIImage *)imageWithAction:(int)action;


// implementation in sub-class
+ (NSArray *)actions;

@end
