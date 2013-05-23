//
//  RecordAndPlaybackControl.m
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import "RecordAndPlayControl.h"
#import "ReadyRecordView.h"
#import "UIViewUtils.h"

@interface RecordAndPlayControl()

@end

@implementation RecordAndPlayControl

- (void)dealloc{
    [_currentView release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        self.state = StateReadyRecord;
        self.currentView = [ReadyRecordView createView];
    }
    
    return self;
}

- (void)showInView:(UIView *)view{
    [view removeAllSubviews];
    [_currentView showInView:view control:self];
}

- (void)updateViewWithInfo:(NSDictionary *)dic{
    [_currentView updateViewWithInfo:dic control:self];
}

@end
