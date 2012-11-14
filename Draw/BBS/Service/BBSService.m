//
//  BBSService.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSService.h"

BBSService *_staticBBSService;

@implementation BBSService

+ (id)defaultService
{
    if (_staticBBSService == nil) {
        _staticBBSService = [[BBSService alloc] init];
    }
    return _staticBBSService;
}
- (void)getBBSBoardList:(id<BBSServiceDelegate>) delegate
{
    
}

@end
