//
//  RecordingView.m
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import "RecordingView.h"
#import "RecordAndPlayControl.h"
#import "AutoCreateViewByXib.h"
#import "ReadyPlayView.h"
#import "StringUtil.h"

@implementation RecordingView

AUTO_CREATE_VIEW_BY_XIB(RecordingView);

- (void)dealloc {
    [_tipLabel release];
    [_counterLabel release];
    [super dealloc];
}

- (void)showInView:(UIView *)view control:(RecordAndPlayControl *)control{
    if (control.state == StateRecording) {
        self.control = control;
        [view addSubview:self];
    }else{
        control.currentView = [ReadyPlayView createView];
        [control showInView:view];
    }
}

- (void)updateViewWithInfo:(NSDictionary *)dic
                   control:(RecordAndPlaybackControl *)control{
    
    NSNumber *leftTime = [dic objectForKey:@(KeyRecordLeftTime)];
    
    static int i = 0;
    i = i % 3 + 1;

    self.tipLabel.text = [@"正在录音" stringByAppendingString:[@"." stringByRepeateTime:i]];

    self.counterLabel.text = [NSString stringWithFormat:@"%d", (int)(leftTime.doubleValue + 0.5)];
}

@end
