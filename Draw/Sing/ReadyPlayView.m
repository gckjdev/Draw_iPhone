//
//  ReadyPlayView.m
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import "ReadyPlayView.h"
#import "RecordAndPlayControl.h"
#import "AutoCreateViewByXib.h"
#import "PlayingView.h"

@implementation ReadyPlayView

AUTO_CREATE_VIEW_BY_XIB(ReadyPlayView);


- (void)dealloc {
    [_tipLabel release];
    [super dealloc];
}

- (void)showInView:(UIView *)view control:(RecordAndPlayControl *)control{
    if (control.state == StateReadyPaly) {
        self.control = control;
        [view addSubview:self];
    }else{
        control.currentView = [PlayingView createView];
        [control showInView:view];
    }
}

- (void)updateViewWithInfo:(NSDictionary *)dic
                   control:(RecordAndPlaybackControl *)control{
    
    NSNumber *duration = [dic objectForKey:@(KeyRecordDuration)];
    NSLog(@"duration: %f", duration.doubleValue);
    
    if (ABS(duration.intValue - 0.0) < 0.01) {
        self.tipLabel.text = @"正在读取文件...";
    }else{
        self.tipLabel.text = [NSString stringWithFormat:@"录音时长：%d秒", [duration intValue]];
    }
}

@end
