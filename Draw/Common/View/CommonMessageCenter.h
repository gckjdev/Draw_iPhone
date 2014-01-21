//
//  CommonMessageCenter.h
//  Draw
//
//  Created by Orange on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommonMessageCenter : NSObject

+ (CommonMessageCenter*) defaultCenter;

- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime;

- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime 
                    isHappy:(BOOL)isHappy;

- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime
               isSuccessful:(BOOL)isSuccessful;

- (void)postWithCustomView:(UIView *)view
                 delayTime:(float)delayTime;

- (void)clear;


@end

#define CLEARMSG              ([[CommonMessageCenter defaultCenter] clear])
#define POSTMSG(msg)          ([[CommonMessageCenter defaultCenter] postMessageWithText:msg delayTime:1.5])
#define POSTMSG2(msg, sec)    ([[CommonMessageCenter defaultCenter] postMessageWithText:msg delayTime:sec])

#define POSTVIEW(v, sec)  ([[CommonMessageCenter defaultCenter] postWithCustomView:v delayTime:sec])
