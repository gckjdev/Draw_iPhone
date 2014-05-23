//
//  OpusDesignTime.m
//  Draw
//
//  Created by qqn_pipi on 13-11-12.
//
//

#import "OpusDesignTime.h"

@implementation OpusDesignTime

- (void)printInfo:(NSString*)stateStr
{
    PPDebug(@"<%@> 作品花费时间%d秒 design state(%d) begin(%d) lastPause(%d) total(%d)", stateStr,
            self.totalTime, self.state, self.beginTime, self.lastPauseTime, self.totalTime);
}

- (id)initWithTime:(int)initTime
{
    self = [super init];
    self.totalTime = initTime;
    self.beginTime = time(0);
    
    [self printInfo:@"init"];
    return self;
}

- (void)start
{
    if (self.state == OPUS_DESIGN_START){
        return;
    }
    
    self.state = OPUS_DESIGN_START;
    self.beginTime = time(0);
    self.lastPauseTime = time(0);
    
    [self printInfo:@"start"];
}

- (void)pause
{
    if (self.state != OPUS_DESIGN_START){
        return;
    }

    self.state = OPUS_DESIGN_PAUSE;

    int addTime = (time(0) - self.lastPauseTime);
    self.totalTime = self.totalTime + addTime;
    
    PPDebug(@"<pause> add %d seconds", addTime);
    self.lastPauseTime = time(0);
    self.beginTime = time(0);
    
    [self printInfo:@"pause"];
}

- (void)resume
{
    if (self.state != OPUS_DESIGN_PAUSE){
        return;
    }
    
    self.state = OPUS_DESIGN_START;
    
    self.beginTime = time(0);
    [self printInfo:@"resume"];
}

- (void)stop
{
    if (self.state != OPUS_DESIGN_START && self.state != OPUS_DESIGN_PAUSE){
        return;
    }
    
    self.state = OPUS_DESIGN_END;

    self.totalTime = self.totalTime + (time(0) - self.beginTime);
    self.lastPauseTime = time(0);   // this is the end time
    
    [self printInfo:@"stop"];
}

@end
