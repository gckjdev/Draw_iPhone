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
- (UIFont *)indexTitleFont
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
@end
