//
//  ChatMessageView.h
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HJManagedImageV;

@interface ChatMessageView : UIView

//- (ChatMessageView*)initWithChatMessage:(NSString*)chatMessage fromUser:(NSString*)fromUserId toUser:(NSString*)toUserId;
//- (void)initWithChatExpression:(NSString*)chatExpression  fromUser:(NSString*)fromUserId toUser:(NSString*)toUserId;

+ (void)showMessage:(NSString*)chatMessage origin:(CGPoint)origin superView:(UIView*)superView;

+ (void)showExpression:(UIImage*)expression title:(NSString*)title origin:(CGPoint)origin superView:(UIView*)superView;

@end

