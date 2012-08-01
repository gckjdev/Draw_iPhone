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

@implementation Draw
@synthesize userId = _userId;
@synthesize nickName = _nickName;;
@synthesize drawActionList = _drawActionList;
@synthesize word = _word;
@synthesize date = _date;
@synthesize avatar = _avatar;
@synthesize languageType = _languageType;

- (void)dealloc{
    [_userId release];
    [_nickName release];
    [_drawActionList release];
    [_word release];
    [_date release];
    [_avatar release];
    [super dealloc];
}


- (NSArray *)drawActionListFromPBActions:(NSArray *)array
{
    if (array) {
        NSMutableArray *list = [NSMutableArray array];
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];        
        for (PBDrawAction *action in array) {
            DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:action];
            [list addObject:drawAction];
            [drawAction release];
        }
        [pool release];
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
        self.word = [Word wordWithText:pbDraw.word level:pbDraw.level];
        self.avatar = pbDraw.avatar;
        self.languageType = pbDraw.language;
        self.date = [NSDate dateWithTimeIntervalSince1970: pbDraw.createDate];
        self.drawActionList = [self drawActionListFromPBActions:pbDraw.drawDataList];
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
        self.drawActionList = drawActionList;
        self.word = word;
        self.date = date;
        self.avatar = avatar;
    }
    return self;
}


@end
