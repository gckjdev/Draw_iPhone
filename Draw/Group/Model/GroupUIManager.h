//
//  GroupUIManager.h
//  Draw
//
//  Created by Gamy on 13-11-18.
//
//

#import <Foundation/Foundation.h>

typedef enum{
    GroupCreateGroup = 1,
    GroupCreateTopic,
    GroupSearchGroup,
    GroupSearchTopic,
    GroupChat,
    GroupAtMe,
    GroupContest,
    
}GroupFooterActionType;



typedef enum {
    ColorStyleRed = 1,
    ColorStyleYellow = 2,
}ColorStyle;


@interface GroupUIManager : NSObject

//image

+ (UIImage *)groupDetailBoundMidImageForStyle:(ColorStyle)style;
+ (UIImage *)groupDetailBoundHeaderImageForStyle:(ColorStyle)style;
+ (UIImage *)groupDetailBoundFooterImageForStyle:(ColorStyle)style;

+ (UIImage *)followedGroupImage;
+ (UIImage *)unfollowingGroupImage;


+ (UIImage *)imageForFooterActionType:(GroupFooterActionType)type;

+ (NSArray *)imagesForFooterActionTypes:(NSArray *)types;


@end
