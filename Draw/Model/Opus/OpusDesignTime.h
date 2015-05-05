//
//  OpusDesignTime.h
//  Draw
//
//  Created by qqn_pipi on 13-11-12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    OPUS_DESIGN_UNKNOWN = 0,
    OPUS_DESIGN_START = 1,
    OPUS_DESIGN_PAUSE = 2,
    OPUS_DESIGN_END = 3,
} OpusDesignTimeState;

@interface OpusDesignTime : NSObject

@property (nonatomic, assign) OpusDesignTimeState state;
@property (nonatomic, assign) time_t beginTime;
@property (nonatomic, assign) time_t lastPauseTime;
@property (nonatomic, assign) time_t totalTime;

- (id)initWithTime:(int)time;
- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

@end
