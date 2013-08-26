//
//  ChatMessageView.h
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"

@interface ChatMessageView : UIView<CMPopTipViewDelegate>

//+ (id)defaultView;

+ (void)showMessage:(NSString*)chatMessage
              title:(NSString*)title
             atView:(UIView *)atView
             inView:(UIView *)inView;

+ (void)showExpression:(UIImage*)expression
                 title:(NSString*)title
                atView:(UIView *)atView
                inView:(UIView *)inView;

@end

