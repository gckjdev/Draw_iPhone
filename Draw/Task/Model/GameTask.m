//
//  GameTask.m
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import "GameTask.h"

@implementation GameTask

- (void)dealloc
{
    PPRelease(_desc);
    PPRelease(_displayName);
    [super dealloc];
}

@end
