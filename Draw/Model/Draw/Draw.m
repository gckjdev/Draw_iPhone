//
//  RemoteDrawData.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "Draw.h"

@implementation Draw
@synthesize userId = _userId;
@synthesize nickName = _nickName;;
@synthesize drawActionList = _drawActionList;
@synthesize word = _word;
@synthesize date = _date;
@synthesize avatar = _avatar;

- (void)dealloc{
    [_userId release];
    [_nickName release];
    [_drawActionList release];
    [_word release];
    [_date release];
    [_avatar release];
    [super dealloc];
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
