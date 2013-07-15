//
//  WordFilterService.m
//  Draw
//
//  Created by qqn_pipi on 13-7-15.
//
//

#import "WordFilterService.h"
#import "SynthesizeSingleton.h"

@implementation WordFilterService

SYNTHESIZE_SINGLETON_FOR_CLASS(WordFilterService)

- (BOOL)containForbiddenWord:(NSString*)text
{
    return NO;
}

@end
