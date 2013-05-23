//
//  RecordAndPlaybackProtocol.h
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecordAndPlayControl;

@protocol RecordAndPlayProtocol <NSObject>

- (void)showInView:(UIView *)view
           control:(RecordAndPlayControl *)control;

- (void)updateViewWithInfo:(NSDictionary *)dic
                   control:(RecordAndPlayControl *)control;

@end
