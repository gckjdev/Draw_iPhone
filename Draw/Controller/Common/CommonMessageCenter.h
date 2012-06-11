//
//  CommonMessageCenter.h
//  Draw
//
//  Created by Orange on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommonMessageCenterDelegate <NSObject>

- (void)didShowedAlert;

@end

@class CommonMessageView;
@interface CommonMessageCenter : NSObject
{
	NSMutableArray *_messages;
	BOOL _active;
	CommonMessageView *_messageView;
	CGRect _messageFrame;
}
@property(nonatomic, retain)NSMutableArray *messages;
@property(nonatomic, assign)id<CommonMessageCenterDelegate>delegate;

+ (CommonMessageCenter*) defaultCenter;
- (void)clearMessages;
- (void)postMessageWithText:(NSString*)text 
                        image:(UIImage*)image 
                    delayTime:(float)delayTime;
- (void)postMessageWithText:(NSString *)text 
                    delayTime:(float)delayTime;
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime 
                    isHappy:(BOOL)isHappy;
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime
               isSuccessful:(BOOL)isSuccessful;

@end

