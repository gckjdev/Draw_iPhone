//
//  ShareUIManager.m
//  Draw
//
//  Created by Gamy on 13-10-11.
//
//

#import "ShareUIManager.h"

#define FONT(x) [UIFont systemFontOfSize:x]
#define BOLD_FONT(x) [UIFont boldSystemFontOfSize:x]

#define AD_FONT(x,y) (ISIPAD?(FONT(x)):(FONT(y)))
#define AD_BOLD_FONT(x,y) (ISIPAD?(BOLD_FONT(x)):(BOLD_FONT(y)))


@implementation ShareUIManager

+ (UIFont *)timelineNickFont
{
    return AD_FONT(26, 14);
}
+ (UIFont *)timelineContentFont
{
    return AD_FONT(25, 12);
}
+ (UIFont *)timelineTimeFont
{
    return AD_FONT(18, 10);
}
+ (UIFont *)timelineStatisticsFont
{
    return AD_FONT(18, 10);    
}


//for comment
+ (UIFont *)commentNickFont
{
    return AD_FONT(23, 12);
}

+ (UIFont *)commentContentFont
{
    return AD_FONT(23, 12);
}

+ (UIFont *)commentTimeFont
{
    return AD_FONT(18, 10);
}


//for comment message
+ (UIFont *)commentMessageNickFont
{
    return AD_FONT(26, 14);
}
+ (UIFont *)commentMessageContentFont
{
    return AD_FONT(23, 12);
}
+ (UIFont *)commentMessageTimeFont
{
    return AD_FONT(21, 11);
}
+ (UIFont *)commentMessageSourceFont
{
    return AD_FONT(21, 11);
}


@end
