//
//  AnnounceView.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AnnounceView.h"
#import "AdAnnounceView.h"
#import "WebAnnounceView.h"

@implementation AnnounceView
@synthesize announce = _announce;

#define ANNOUNCE_FRAME ([DeviceDetection isIPAD]?CGRectMake(0, 0, 300 * 2, 200 * 2):CGRectMake(0, 0, 300, 200))

- (id)initWithAnnounce:(Announce *)anounce
{
    self = [super initWithFrame:ANNOUNCE_FRAME];
    if (self) {
        self.announce = anounce;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_announce);
    [super dealloc];
    
}
+ (AnnounceView *)creatAnnounceView:(Announce *)annnouce
{
    if (annnouce == nil) {
        return nil;
    }
    switch (annnouce.type) {
        case AnnounceTypeAd:
            return [[[AdAnnounceView alloc] initWithAnnounce:annnouce] autorelease];
        case AnnounceTypeLocal:
        case AnnounceTypeRemote:
            return [[[WebAnnounceView alloc] initWithAnnounce:annnouce] autorelease];
        default:
            return nil;
    }
}

- (void)loadView
{
    //should be override by the sub classes.
}

@end
