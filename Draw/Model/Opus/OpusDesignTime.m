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
    PPDebug(@"<%@> design state(%d) begin(%d) lastPause(%d) total(%d)", stateStr,
            self.state, self.beginTime, self.lastPauseTime, self.totalTime);
}

- (id)initWithTime:(int)time
{
    self = [super init];
    self.totalTime = time;
    [self printInfo:@"init"];
    return self;
}

- (void)start
{
    if (self.state == OPUS_DESIGN_START){
        return;
    }
    
    self.state = OPUS_DESIGN_START;

    if (self.state != OPUS_DESIGN_PAUSE){
        self.beginTime = time(0);
        self.lastPauseTime = time(0);
    }
    
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
    
    [self printInfo:@"pause"];
}

- (void)stop
{
    if (self.state != OPUS_DESIGN_START && self.state != OPUS_DESIGN_PAUSE){
        return;
    }
    
    self.state = OPUS_DESIGN_END;

    self.totalTime = self.totalTime + (time(0) - self.lastPauseTime);
    self.lastPauseTime = time(0);   // this is the end time
    
    [self printInfo:@"stop"];
    
    
}

@end
