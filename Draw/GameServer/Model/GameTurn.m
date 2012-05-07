//
//  GameTurn.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameTurn.h"

@implementation GameTurn

@synthesize round = _round;
@synthesize playResultList = _playResultList;
@synthesize userCommentList = _userCommentList;
@synthesize drawActionList = _drawActionList;
@synthesize currentPlayUserId = _currentPlayUserId;
@synthesize nextPlayUserId = _nextPlayUserId;
@synthesize lastPlayUserId = _lastPlayUserId;
@synthesize word = _word;
@synthesize level = _level;
@synthesize lastWord = _lastWord;
@synthesize language = _language;
- (void)dealloc
{
    [_lastWord release];
    [_word release];
    [_currentPlayUserId release];
    [_nextPlayUserId release];
    [_lastPlayUserId release];
    [_playResultList release];
    [_userCommentList release];
    [_drawActionList release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _drawActionList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[round=%d, currentPlayUserId=%@, nextPlayUserId=%@]",
            _round, _currentPlayUserId, _nextPlayUserId];
}

- (void)updateLastWord
{
    self.lastWord = self.word;
}
- (void)resetData
{
    self.word = nil;
    self.level = 0;
    self.language = 0;
    [self.drawActionList removeAllObjects];
}
@end
