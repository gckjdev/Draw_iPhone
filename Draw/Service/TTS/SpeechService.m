//
//  SpeechService.m
//  Draw
//
//  Created by haodong qiu on 12年5月31日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "SpeechService.h"
#import "LogUtil.h"


#define APPID @"4fc430af"   //应用ID
#define ENGINE_URL @"http://dev.voicecloud.cn:1028/index.htm"

@interface SpeechService()

@property (retain, nonatomic)IFlySynthesizerControl *iFlySynthesizerControl;

@end


static SpeechService *_defaultSpeechService = nil;


@implementation SpeechService
@synthesize iFlySynthesizerControl = _iFlySynthesizerControl;

- (void)dealloc
{
    [_iFlySynthesizerControl release];
    [super dealloc];
}

+ (SpeechService *)defaultService
{
    if (_defaultSpeechService == nil) {
        _defaultSpeechService = [[SpeechService alloc] init];
    }
    return _defaultSpeechService;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *initParam = [[NSString alloc] initWithFormat:
                               @"server_url=%@,appid=%@",ENGINE_URL,APPID];
        _iFlySynthesizerControl = [[IFlySynthesizerControl alloc] initWithOrigin:CGPointMake(1, 1) theInitParam:initParam];
        [_iFlySynthesizerControl setShowUI:NO];
        _iFlySynthesizerControl.delegate = self;
    }
    return self;
}

- (void)play:(NSString *)text gender:(BOOL)isMale
{
    [self cancel];
    [_iFlySynthesizerControl setText:text theParams:nil];
    
    if (isMale) {
        [_iFlySynthesizerControl setVoiceName:@"xiaoyu"];
    }else {
        [_iFlySynthesizerControl setVoiceName:@"xiaoyan"];
    }
    
    //speed 0至10
    [_iFlySynthesizerControl setSpeed:5];
	[_iFlySynthesizerControl start];
}

- (void)cancel
{
    [_iFlySynthesizerControl cancel];
}

#pragma mark - IFlySynthesizerControlDelegate
- (void)onSynthesizerEnd:(IFlySynthesizerControl *)iFlySynthesizerControl theError:(SpeechError) error
{
    if (error != 0) {
        PPDebug(@"<SpeechService> onSynthesizerEnd:%@",[_iFlySynthesizerControl getErrorDescription:error]);
    }
    //PPDebug(@"下载流量%d",[_iFlySynthesizerControl getDownflow]);
}

- (void)onSynthesizerBufferProgress:(float)bufferProgress
{
    PPDebug(@"<SpeechService> onSynthesizerBufferProgress:%f",bufferProgress);
}

- (void)onSynthesizerPlayProgress:(float)playProgress
{
    PPDebug(@"<SpeechService> onSynthesizerPlayProgress:%f",playProgress);
}

@end
