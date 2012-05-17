//
//  RemoteDrawData.h
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawAction.h"

@interface RemoteDrawData : NSObject

@property (retain, nonatomic) NSString *userId;
@property (retain, nonatomic) NSString *nickName;
@property (retain, nonatomic) DrawAction *drawAction;
@property (retain, nonatomic) NSString *word;
@property (retain, nonatomic) NSDate *date;
@property (retain, nonatomic) NSString *avatar;

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
          drawAction:(DrawAction *)drawAction 
                word:(NSString *)word 
                date:(NSDate *)date 
              avatar:(NSString *)avatar;

@end
