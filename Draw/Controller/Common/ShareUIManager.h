//
//  ShareUIManager.h
//  Draw
//
//  Created by Gamy on 13-10-11.
//
//

#import <Foundation/Foundation.h>

@interface ShareUIManager : NSObject

//for bbs post && timeline
+ (UIFont *)timelineNickFont;
+ (UIFont *)timelineContentFont;
+ (UIFont *)timelineTimeFont;
+ (UIFont *)timelineStatisticsFont;

//for comment
+ (UIFont *)commentNickFont;
+ (UIFont *)commentContentFont;
+ (UIFont *)commentTimeFont;

//for comment message
+ (UIFont *)commentMessageNickFont;
+ (UIFont *)commentMessageContentFont;
+ (UIFont *)commentMessageTimeFont;
+ (UIFont *)commentMessageSourceFont;

@end
