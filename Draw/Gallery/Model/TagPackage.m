//
//  TagPackage.m
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "TagPackage.h"

@implementation TagPackage

- (void)dealloc
{
    [_tagArray release];
    [_tagPackageName release];
    [super dealloc];
}

@end
