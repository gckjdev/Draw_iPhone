//
//  ShareUIManager.m
//  Draw
//
//  Created by Gamy on 13-10-11.
//
//

#import "ShareUIManager.h"



@implementation ShareUIManager

+ (UIFont *)timelineNickFont
{
    return CELL_NICK_FONT;
}
+ (UIFont *)timelineContentFont
{
    return CELL_CONTENT_FONT;
}
+ (UIFont *)timelineTimeFont
{
    return CELL_SMALLTEXT_FONT;
}
+ (UIFont *)timelineStatisticsFont
{
    return CELL_SMALLTEXT_FONT;
}


//for comment
+ (UIFont *)commentNickFont
{
    return CELL_NICK_FONT;
}

+ (UIFont *)commentContentFont
{
    return CELL_CONTENT_FONT;
}

+ (UIFont *)commentTimeFont
{
    return CELL_SMALLTEXT_FONT;
}


//for comment message
+ (UIFont *)commentMessageNickFont
{
    return CELL_NICK_FONT;
}
+ (UIFont *)commentMessageContentFont
{
    return CELL_CONTENT_FONT;
}
+ (UIFont *)commentMessageTimeFont
{
    return CELL_SMALLTEXT_FONT;
}
+ (UIFont *)commentMessageSourceFont
{
    return CELL_REPLY_SOURCE_FONT;
}


@end
