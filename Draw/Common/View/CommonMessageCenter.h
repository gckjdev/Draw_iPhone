//
//  CommonMessageCenter.h
//  Draw
//
//  Created by Orange on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol CommonMessageCenterDelegate <NSObject>
//
//- (void)didShowedAlert;
//
//@end

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

@end

