//
//  ReadyRecordView.m
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import "ReadyRecordView.h"
#import "RecordAndPlayControl.h"
#import "AutoCreateViewByXib.h"
#import "RecordingView.h"

@interface ReadyRecordView()

@end

@implementation ReadyRecordView

AUTO_CREATE_VIEW_BY_XIB(ReadyRecordView);

- (void)dealloc {
    [_tipLabel release];
    [super dealloc];
}

- (void)showInView:(UIView *)view control:(RecordAndPlayControl *)control{
    if (control.state == StateReadyRecord) {
        self.control = control;
        [view addSubview:self];
    }else{
        control.currentView = [RecordingView createView];
        [control showInView:view];
    }
}

- (void)updateViewWithInfo:(NSDictionary *)dic
                   control:(RecordAndPlaybackControl *)control{
    NSNumber *limitTime = [dic objectForKey:@(KeyRecordLimited)];
    self.tipLabel.text = [NSString stringWithFormat:@"录音上限：%d秒", [limitTime intValue]];
}



@end
