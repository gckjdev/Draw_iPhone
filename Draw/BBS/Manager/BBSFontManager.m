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
#define FONT(x) ([UIFont systemFontOfSize:x])
#define BOLDFONT(x) ([UIFont boldSystemFontOfSize:x])

+ (id)defaultManager
{
    if (_staticBBSFontManager == nil) {
        _staticBBSFontManager = [[BBSFontManager alloc] init];
    }
    return _staticBBSFontManager;
}


- (UIFont *)indexTabFont
{
    return ISIPHONE ? FONT(12) : FONT(24);
}
- (UIFont *)bbsTitleFont
{
    return ISIPHONE ? BOLDFONT(18) : BOLDFONT(36);
}
- (UIFont *)indexCountFont
{
    return ISIPHONE ? FONT(11) : FONT(22);
}
- (UIFont *)indexLastPostTextFont
{
    return ISIPHONE ? FONT(11) : FONT(22);
}
- (UIFont *)indexLastPostNickFont
{
    return ISIPHONE ? FONT(11) : FONT(22);
}
- (UIFont *)indexLastPostDateFont
{
    return ISIPHONE ? FONT(9) : FONT(18);
}

- (UIFont *)indexBoardNameFont
{
    return ISIPHONE ? FONT(11) : FONT(22);
}
- (UIFont *)indexSectionNameFont
{
    return ISIPHONE ? FONT(16) : FONT(32);
}
- (UIFont *)indexBadgeFont
{
    return ISIPHONE ? BOLDFONT(11) : BOLDFONT(22);
}


//Post list font
- (UIFont *)postNickFont{
   return ISIPHONE ? FONT(15) : FONT(15*2); 
}
- (UIFont *)postContentFont{
    return ISIPHONE ? FONT(14) : FONT(14*2);
}
- (UIFont *)postDateFont{
    return ISIPHONE ? FONT(9) : FONT(9*2);
}
- (UIFont *)postRewardFont{
    return ISIPHONE ? FONT(8) : FONT(8*2);
}
- (UIFont *)postActionFont{
     return ISIPHONE ? FONT(8) : FONT(8*2);
}

//post detail font
- (UIFont *)detailHeaderFont
{
    return ISIPHONE ? BOLDFONT(12) : BOLDFONT(12*2);
}
- (UIFont *)detailActionFont
{
    return ISIPHONE ? BOLDFONT(14) : BOLDFONT(14*2);
}
- (UIFont *)detailOptionActionFont
{
    return ISIPHONE ? BOLDFONT(12) : BOLDFONT(12*2);
}
@end
