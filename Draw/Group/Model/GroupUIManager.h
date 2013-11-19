//
//  GroupUIManager.h
//  Draw
//
//  Created by Gamy on 13-11-18.
//
//

#import <Foundation/Foundation.h>

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


@end
