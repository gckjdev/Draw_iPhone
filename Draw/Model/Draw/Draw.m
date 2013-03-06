//
//  RemoteDrawData.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "Draw.h"
#import "DrawAction.h"
#import "GameBasic.pb.h"
#import "Draw.pb.h"
#import "Word.h"
#import "TimeUtils.h"
#import "ConfigManager.h"

@implementation Draw
@synthesize userId = _userId;
@synthesize nickName = _nickName;;
@synthesize drawActionList = _drawActionList;
@synthesize word = _word;
@synthesize date = _date;
@synthesize avatar = _avatar;
@synthesize languageType = _languageType;

- (void)dealloc{
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_drawActionList);
    PPRelease(_word);
    PPRelease(_date);
    PPRelease(_avatar);
    PPRelease(_drawBg);
    [super dealloc];
}


- (NSArray *)drawActionListFromPBActions:(NSArray *)array
{
    if (array) {
        NSMutableArray *list = [NSMutableArray array];
        for (PBDrawAction *action in array) {
            DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:action];
            [list addObject:drawAction];
            [drawAction release];
        }
        return list;
    }
    return nil;
}

- (id)initWithPBDraw:(PBDraw *)pbDraw
{
    self = [super init];
    if (self && pbDraw) {
        self.userId = pbDraw.userId;
        self.nickName = pbDraw.nickName;
        self.word = [Word wordWithText:pbDraw.word level:pbDraw.level score:pbDraw.score];
        self.avatar = pbDraw.avatar;
        self.languageType = pbDraw.language;
        self.date = [NSDate dateWithTimeIntervalSince1970: pbDraw.createDate];
        self.drawActionList = [NSMutableArray arrayWithArray:[self drawActionListFromPBActions:pbDraw.drawDataList]];
        self.version = pbDraw.version;
        self.drawBg = pbDraw.drawBg;
    }
    return self;
}

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
          drawActionList:(NSArray *)drawActionList 
                word:(Word *)word 
                date:(NSDate *)date 
              avatar:(NSString *)avatar
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
        self.drawActionList = [NSMutableArray arrayWithArray:drawActionList];
        self.word = word;
        self.date = date;
        self.avatar = avatar;
        self.version = [ConfigManager currentDrawDataVersion];
    }
    return self;
}



#define USERID @"userId"
#define NICKNAME @"nick"
#define WORD @"word"
#define DATE @"date"
#define AVATAR @"avatar"
#define DRAW_ACTION_LIST @"action_list"
#define LANGUAGE @"language"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_userId forKey:USERID];
    [aCoder encodeObject:_nickName forKey:NICKNAME];
    [aCoder encodeObject:_avatar forKey:AVATAR];
    [aCoder encodeObject:_date forKey:DATE];
    [aCoder encodeInt:_languageType forKey:LANGUAGE];
    [aCoder encodeObject:_word forKey:WORD];
    [aCoder encodeObject:_drawActionList forKey:DRAW_ACTION_LIST];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.userId = [aDecoder decodeObjectForKey:USERID];
        self.nickName = [aDecoder decodeObjectForKey:NICKNAME];
        self.avatar = [aDecoder decodeObjectForKey:AVATAR];
        self.languageType = [aDecoder decodeIntForKey:LANGUAGE];
        self.word = [aDecoder decodeObjectForKey:WORD];
        self.date = [aDecoder decodeObjectForKey:DATE];
        self.drawActionList = [aDecoder decodeObjectForKey:DRAW_ACTION_LIST];
    }
    return self;
}

- (BOOL)isNewVersion
{
    return [ConfigManager currentDrawDataVersion] < self.version;
}

@end
