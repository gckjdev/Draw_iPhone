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
#import "Photo.pb.h"

#define TAG_SEP @"^"

@implementation GalleryService

SYNTHESIZE_SINGLETON_FOR_CLASS(GalleryService)

- (NSString*)tagArrayStringBySet:(NSSet*)tagSet
{
    NSString* str = @"";
    
    return @"tag1^tag2^tag3";
    for (NSString* tag in tagSet) {
        str = [NSString stringWithFormat:@"%@%@%@",str, TAG_SEP, tag];
    }
    return str;
}

- (void)addUserPhoto:(NSString*)photoUrl
                name:(NSString*)name
              tagSet:(NSSet*)tagSet
         resultBlock:(void(^)(int resultCode))resultBlock
{
    PPDebug(@"<addUserPhoto> favor image %@ with name %@ ,tag %@", photoUrl, name, [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
//    NSString* tagArrayString = [self tagArrayStringBySet:tagSet];
    
    PBUserPhoto_Builder* builder = [PBUserPhoto builder];
    
    [builder setName:name];
    [builder setUrl:photoUrl];
    [builder setUserId:userId];
    [builder setCreateDate:time(0)];
    for (NSString* tag in tagSet) {
        [builder addTags:tag];
    }
    
    PBUserPhoto* photo = [builder build];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest addUserPhoto:TRAFFIC_SERVER_URL
                                                                 appId:appId
                                                                userId:userId
                                                                  data:[photo data]];
        
//        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
//                opusId, actionName, output.resultCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)getUserPhotoWithTagSet:(NSSet*)tagSet
                        offset:(int)offset
                         limit:(int)limit
                   resultBlock:(void(^)(int resultCode, NSArray* resultArray))resultBlock
{
    PPDebug(@"<getUserPhotoWithTagSet> get image with tag %@", [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    NSString* tagArrayString = [self tagArrayStringBySet:tagSet];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getUserPhoto:TRAFFIC_SERVER_URL
                                                                 appId:appId
                                                                userId:userId
                                                              tagArray:tagArrayString
                                                                offset:offset
                                                                 limit:limit];
        
        //        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
        //                opusId, actionName, output.resultCode);
        
        NSInteger resultCode = output.resultCode;
        NSArray *list = nil;
        @try {
            PBUserPhotoList *response = [PBUserPhotoList parseFromData:output.responseData];
//            resultCode = [response resultCode];
            list = response.photoListList;
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode, list);
        });
    });
}

- (void)updateUserPhoto:(NSString*)photoId
               photoUrl:(NSString*)photoUrl
                   name:(NSString*)name
                 tagSet:(NSSet*)tagSet
            resultBlock:(void(^)(int resultCode))resultBlock
{
    PPDebug(@"<updateUserPhoto> photoId = %@,  url = %@ with name %@ ,tag %@", photoId, photoUrl, name, [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
//    NSString* tagArrayString = [self tagArrayStringBySet:tagSet];
    
    PBUserPhoto_Builder* builder = [PBUserPhoto builder];
    
    [builder setName:name];
    [builder setUrl:photoUrl];
    [builder setUserId:userId];
    [builder setPhotoId:photoId];
    [builder setCreateDate:time(0)];
    for (NSString* tag in tagSet) {
        [builder addTags:tag];
    }
    
    PBUserPhoto* photo = [builder build];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest updateUserPhoto:TRAFFIC_SERVER_URL
                                                                    appId:appId
                                                                   userId:userId
                                                                     data:[photo data]];
        
        //        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
        //                opusId, actionName, output.resultCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)deleteUserPhoto:(NSString*)photoId
            resultBlock:(void(^)(int resultCode))resultBlock
{
    PPDebug(@"<deleteUserPhoto> photoId = %@", photoId);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest deleteUserPhoto:TRAFFIC_SERVER_URL
                                                                    appId:appId
                                                                   userId:userId
                                                                  photoId:photoId];
        
        //        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
        //                opusId, actionName, output.resultCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

@end
