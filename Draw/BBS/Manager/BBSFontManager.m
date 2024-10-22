//
//  BBSFontManager.m
//  Draw
//
//  Created by gamy on 12-11-27.
//
//

#import "BBSFontManager.h"

static BBSFontManager* _staticBBSFontManager;

@implementation BBSFontManager


#define ISIPHONE (![DeviceDetection isIPAD])
//#define FONT(x) ([UIFont systemFontOfSize:x])
#define BOLDFONT(x) ([UIFont boldSystemFontOfSize:x])

+ (id)defaultManager
{
    if (_staticBBSFontManager == nil) {
        _staticBBSFontManager = [[BBSFontManager alloc] init];
    }
    return _staticBBSFontManager;
}

#pragma mark common font
- (UIFont *)bbsTitleFont
{
    return ISIPHONE ? BOLDFONT(18) : BOLDFONT(36);
}
- (UIFont *)bbsOptionTitleFont
{
    return ISIPHONE ? BOLDFONT(12) : BOLDFONT(12*2);
}

#pragma mark index page font
- (UIFont *)indexTabFont
{
    return ISIPHONE ? FONT(11) : FONT(24);
}
- (UIFont *)indexCountFont
{
    return ISIPHONE ? FONT(11) : FONT(20);
}
- (UIFont *)indexLastPostTextFont
{
    return ISIPHONE ? FONT(9) : FONT(18);
}
- (UIFont *)indexLastPostNickFont
{
    return ISIPHONE ? FONT(11) : FONT(20);
}
- (UIFont *)indexLastPostDateFont
{
    return ISIPHONE ? FONT(9) : FONT(18);
}

- (UIFont *)indexBoardNameFont
{
    return ISIPHONE ? FONT(11) : FONT(20);
}
- (UIFont *)indexSectionNameFont
{
    return ISIPHONE ? FONT(14) : FONT(26);
}
- (UIFont *)indexBadgeFont
{
    return ISIPHONE ? BOLDFONT(11) : BOLDFONT(20);
}

#pragma mark post list page font
//Post list font
- (UIFont *)postNickFont{
//   return ISIPHONE ? FONT(15) : FONT(15*2);
    return [ShareUIManager timelineNickFont];
}
- (UIFont *)postContentFont{

//    return ISIPHONE ? FONT(14) : FONT(11*2);
    return [ShareUIManager timelineContentFont];
}
- (UIFont *)postDateFont{
//    return ISIPHONE ? FONT(9) : FONT(9*2);
    return [ShareUIManager timelineTimeFont];
}
- (UIFont *)postRewardFont{
//    return ISIPHONE ? FONT(8) : FONT(8*2);
    return [ShareUIManager timelineStatisticsFont];
}
- (UIFont *)postActionFont{
//     return ISIPHONE ? FONT(8) : FONT(8*2);
    return [ShareUIManager timelineStatisticsFont];
}
- (UIFont *)postTopFont{
    return ISIPHONE ? FONT(9) : FONT(9*2);
}

- (UIFont *)boardAdminTitleFont
{
    return CELL_NICK_FONT; // ISIPHONE ? FONT(14) : FONT(14*2);
}
- (UIFont *)boardAdminNickFont
{
    return CELL_NICK_FONT; // ISIPHONE ? FONT(14) : FONT(14*2);
}


#pragma mark post detail page font
//post detail font
- (UIFont *)detailHeaderFont
{
    return ISIPHONE ? BOLDFONT(12) : BOLDFONT(12*2);
}

//action
- (UIFont *)actionContentFont
{
    return [ShareUIManager commentContentFont];
}
- (UIFont *)actionNickFont
{
    return [ShareUIManager commentNickFont];
}
- (UIFont *)actionDateFont
{
    return [ShareUIManager commentTimeFont];
}


- (UIFont *)actionSourceFont{
//    return ISIPHONE ? FONT(12) : FONT(12*2);
    return [ShareUIManager commentMessageSourceFont];
}

- (UIFont *)myActionContentFont
{
    return [ShareUIManager commentMessageContentFont];
}
- (UIFont *)myActionDateFont
{
    return [ShareUIManager commentMessageTimeFont];
}
- (UIFont *)myActionNickFont
{
    return [ShareUIManager commentMessageNickFont];
}


#pragma mark creation font
- (UIFont *)creationDefaulFont
{
    return ISIPHONE ? BOLDFONT(12) : BOLDFONT(12*2);
}
@end
