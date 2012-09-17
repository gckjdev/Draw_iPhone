//
//  Contest.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Contest.h"

@implementation Contest
@synthesize contestId = _contestId;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize version = _version;
@synthesize type = _type;
@synthesize status = _status;
@synthesize participantCount = _participantCount;
@synthesize opusCount = _opusCount;
@synthesize imageUrl = _imageUrl;
@synthesize title = _title;

@synthesize topicDesc = _topicDesc;
@synthesize awardDesc = _awardDesc;
@synthesize ruleDesc = _ruleDesc;


- (void)dealloc
{
    PPRelease(_contestId);
    PPRelease(_startDate);
    PPRelease(_endDate);
    PPRelease(_version);
    PPRelease(_title);
    PPRelease(_imageUrl);
    
    PPRelease(_topicDesc);
    PPRelease(_ruleDesc);
    PPRelease(_awardDesc);
    [super dealloc];
}

@end
