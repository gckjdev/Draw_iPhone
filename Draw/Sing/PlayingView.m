//
//  PlayingView.m
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import "PlayingView.h"
#import "RecordAndPlayControl.h"
#import "AutoCreateViewByXib.h"
#import "ReadyRecordView.h"

@implementation PlayingView

AUTO_CREATE_VIEW_BY_XIB(PlayingView);

- (void)dealloc {
    [_tipLabel release];
    [super dealloc];
}

- (void)showInView:(UIView *)view control:(RecordAndPlayControl *)control{
    if (control.state == StatePlaying) {
        self.control = control;
        [view addSubview:self];
    }else{
        control.currentView = [ReadyRecordView createView];
        [control showInView:view];
    }
}

- (void)updateViewWithInfo:(NSDictionary *)dic
                   control:(RecordAndPlaybackControl *)control{
    NSNumber *duration = [dic objectForKey:@(KeyRecordDuration)];
    
    self.tipLabel.text = [NSString stringWithFormat:@"录音时长：%d秒", [duration intValue]];
}


@end
