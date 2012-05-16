//
//  RemoteDrawData.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "RemoteDrawData.h"

@implementation RemoteDrawData
@synthesize userId = _userId;
@synthesize nickName = _nickName;;
@synthesize drawAction = _drawAction;
@synthesize word = _word;
@synthesize date = _date;
@synthesize avatar = _avatar;

- (void)dealloc{
    [_userId release];
    [_nickName release];
    [_drawAction release];
    [_word release];
    [_date release];
    [_avatar release];
    [super dealloc];
}


- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
          drawAction:(DrawAction *)drawAction 
                word:(NSString *)word 
                date:(NSDate *)date 
              avatar:(NSString *)avatar
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
        self.drawAction = drawAction;
        self.word = word;
        self.date = date;
        self.avatar = avatar;
    }
    return self;
}


@end
