//
//  AskPsService.m
//  Draw
//
//  Created by haodong on 13-6-14.
//
//

#import "AskPsService.h"
#import "SynthesizeSingleton.h"
#import "PPGameNetworkRequest.h"

@implementation AskPsService

SYNTHESIZE_SINGLETON_FOR_CLASS(AskPsService)

- (void)awardIngot:(id<AskPsServiceDelegate>)delegate
            userId:(NSString *)userId
{
    dispatch_async(workingQueue, ^{
        //to do
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAwardIngot:)]) {
                //[delegate didAwardIngot:0];
            }
        });
    });
}

@end
