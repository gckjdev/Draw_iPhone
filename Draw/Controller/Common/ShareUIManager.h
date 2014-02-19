//
//  ShareUIManager.h
//  Draw
//
//  Created by Gamy on 13-10-11.
//
//

#import <Foundation/Foundation.h>


//SET FONT
#ifndef _SHAREUIMANAGER_METHOD_
    #define _SHAREUIMANAGER_METHOD_

//FONT METHOD
    #define FONT(x) [UIFont systemFontOfSize:x]
    #define BOLD_FONT(x) [UIFont boldSystemFontOfSize:x]
    #define AD_FONT(x,y) (ISIPAD?(FONT(x)):(FONT(y)))
    #define AD_BOLD_FONT(x,y) (ISIPAD?(BOLD_FONT(x)):(BOLD_FONT(y)))

//SIZE METHOD
    #define AD_VALUE(x,y) (ISIPAD?(x):(y))

#endif


//Cell的昵称字体，例如FeedCell，PostCell，FriendCell的昵称
#define CELL_NICK_FONT          AD_FONT(22, 13)

//Cell 的内容字体
#define CELL_CONTENT_FONT       AD_FONT(20, 12)

//Cell的所回复的评论的字体
#define CELL_REPLY_SOURCE_FONT  AD_FONT(18, 11)

//Cell的小字，例如说明，时间，小吉号，猜对数目，评论数目等
#define CELL_SMALLTEXT_FONT    AD_FONT(14, 10)



// Cell 的默认高度：好友列表，聊天列表
#define CELL_CONST_HEIGHT AD_VALUE(132.0f,66.0f)



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
