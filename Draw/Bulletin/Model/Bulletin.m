//
//  Bulletin.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "Bulletin.h"
#import "BulletinNetworkConstants.h"
#import "TimeUtils.h"


#define CODE_KEY_TYPE   @"type"
#define CODE_KEY_DATE   @"date"
#define CODE_KEY_BULLETIN_ID    @"bulletinId"
#define CODE_KEY_MESSAGE    @"message"
#define CODE_KEY_GAME_ID    @"gameId"
#define CODE_KEY_FUNCTION   @"function"
#define CODE_KEY_HAS_READ   @"hasRead"
#define CODE_KEY_URL        @"url"


@interface Bulletin (PrivateMethod)


@end

@implementation Bulletin

- (id)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        NSString* dateStr = [dict objectForKey:PARA_BULLETIN_DATE];
        self.date = dateFromUTCStringByFormat(dateStr, DEFAULT_DATE_FORMAT);
        self.bulletinId = [dict objectForKey:PARA_BULLETIN_ID];
        self.message = [dict objectForKey:PARA_BULLETIN_MESSAGE];
        self.gameId = [dict objectForKey:PARA_BULLETIN_GAME_ID];
        self.function = [dict objectForKey:PARA_BULLETIN_FUNCTION];
        self.type = [((NSString*)[dict objectForKey:PARA_BULLETIN_TYPE]) intValue];
        self.url = [dict objectForKey:PARA_BULLETIN_URL];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:CODE_KEY_TYPE];
    [aCoder encodeObject:_bulletinId forKey:CODE_KEY_BULLETIN_ID];
    [aCoder encodeObject:_message forKey:CODE_KEY_MESSAGE];
    [aCoder encodeObject:_gameId forKey:CODE_KEY_GAME_ID];
    [aCoder encodeObject:_date forKey:CODE_KEY_DATE];
    [aCoder encodeObject:_function forKey:CODE_KEY_FUNCTION];
    [aCoder encodeBool:_hasRead forKey:CODE_KEY_HAS_READ];
    [aCoder encodeObject:_url forKey:CODE_KEY_URL];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeIntegerForKey:CODE_KEY_TYPE];
        self.bulletinId = [aDecoder decodeObjectForKey:CODE_KEY_BULLETIN_ID];
        self.message = [aDecoder decodeObjectForKey:CODE_KEY_MESSAGE];
        self.gameId = [aDecoder decodeObjectForKey:CODE_KEY_GAME_ID];
        self.date = [aDecoder decodeObjectForKey:CODE_KEY_DATE];
        self.function = [aDecoder decodeObjectForKey:CODE_KEY_FUNCTION];
        self.hasRead = [aDecoder decodeBoolForKey:CODE_KEY_HAS_READ];
        self.url = [aDecoder decodeObjectForKey:CODE_KEY_URL];
    }
    return self;
}

@end
