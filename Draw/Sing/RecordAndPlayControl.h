//
//  RecordAndPlayControl.h
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordAndPlayProtocol.h"

typedef enum _StateRecordAndPlay {
    StateReadyRecord = 0,
    StateRecording = 2,
    StateReadyPaly = 3,
    StatePlaying = 4
} StateRecordAndPlay;

typedef enum _KeyRecordAndPlayInfo {
    KeyRecordLimited = 1,
    KeyRecordLeftTime = 2,
    KeyRecordDuration = 3,
} KeyRecordAndPlayInfo;

@class RecordAndPlaybackControl;

@protocol RecordAndPlayDelegate <NSObject>

@required
- (void)didClickControl:(RecordAndPlayControl *)control;

@end

@interface RecordAndPlayControl : NSObject

@property (assign, nonatomic) id<RecordAndPlayDelegate> delegate;

@property (assign, nonatomic) StateRecordAndPlay state;
@property (retain, nonatomic) UIView <RecordAndPlayProtocol> *currentView;

- (void)showInView:(UIView *)view;
- (void)updateViewWithInfo:(NSDictionary *)dic;

@end
