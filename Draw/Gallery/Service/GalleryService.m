//
//  GalleryService.m
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "GalleryService.h"
#import "SynthesizeSingleton.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "UserManager+DiceUserManager.h"


#define TAG_SEP @"^"

@implementation GalleryService

SYNTHESIZE_SINGLETON_FOR_CLASS(GalleryService)

- (NSString*)tagArrayStringBySet:(NSSet*)tagSet
{
    NSString* str = @"";
    for (NSString* tag in tagSet) {
        str = [NSString stringWithFormat:@"%@%@%@",str, TAG_SEP, tag];
    }
    return str;
}

- (void)favorImage:(NSString*)url
              name:(NSString*)name
            tagSet:(NSSet*)tagSet
       resultBlock:(void(^)(int resultCode))resultBlock
{
    PPDebug(@"<GalleryService> favor image %@ with name %@ ,tag %@", url, name, [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    NSString* tagArrayString = [self tagArrayStringBySet:tagSet];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest favorGalleryPicture:TRAFFIC_SERVER_URL
                                                                     appId:appId
                                                                       userId:userId
                                                                          url:url
                                                                         name:name
                                                                     tagArray:tagArrayString];
        
//        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
//                opusId, actionName, output.resultCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)getGalleryImageWithTagSet:(NSSet*)tagSet
                      resultBlock:(void(^)(int resultCode, NSArray* resultArray))resultBlock
{
    PPDebug(@"<GalleryService> get image with tag %@", [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    NSString* tagArrayString = [self tagArrayStringBySet:tagSet];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getGalleryImage:TRAFFIC_SERVER_URL
                                                                    appId:appId
                                                                   userId:userId
                                                                     tagArray:tagArrayString];
        
        //        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
        //                opusId, actionName, output.resultCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode, nil);
        });
    });
}

@end
