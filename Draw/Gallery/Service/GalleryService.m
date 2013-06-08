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
#import "GameMessage.pb.h"

#define TAG_SEP @"$"

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
               usage:(PBPhotoUsage)usage
         resultBlock:(void(^)(int resultCode, PBUserPhoto* photo))resultBlock
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
    [builder setUsage:usage];
    
    PBUserPhoto* photo = [builder build];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest addUserPhoto:SERVER_URL
                                                                 appId:appId
                                                                userId:userId
                                                                  data:[photo data]];
        
//        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
//                opusId, actionName, output.resultCode);
        NSInteger resultCode = output.resultCode;
        PBUserPhoto *photo = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            photo = response.userPhoto;
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode, photo);
        });
    });
}

- (void)getUserPhotoWithTagSet:(NSSet*)tagSet
                         usage:(PBPhotoUsage)usage
                        offset:(int)offset
                         limit:(int)limit
                   resultBlock:(void(^)(int resultCode, NSArray* resultArray))resultBlock
{
    PPDebug(@"<getUserPhotoWithTagSet> get image with tag %@", [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    NSString* tagArrayString = [self tagArrayStringBySet:tagSet];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getUserPhoto:SERVER_URL
                                                                 appId:appId
                                                                userId:userId
                                                              tagArray:tagArrayString
                                                                 usage:usage
                                                                offset:offset
                                                                 limit:limit];
        
        //        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
        //                opusId, actionName, output.resultCode);
        
        NSInteger resultCode = output.resultCode;
        NSArray *list = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            list = response.userPhotoListList;
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
            resultBlock:(void(^)(int resultCode, PBUserPhoto* photo))resultBlock
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
        CommonNetworkOutput* output = [GameNetworkRequest addUserPhoto:SERVER_URL
                                                                    appId:appId
                                                                   userId:userId
                                                                     data:[photo data]];
        
        //        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
        //                opusId, actionName, output.resultCode);
        NSInteger resultCode = output.resultCode;
        PBUserPhoto *photo = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            photo = response.userPhoto;
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode, photo);
        });
    });
}

- (void)deleteUserPhoto:(NSString*)userPhotoId
                  usage:(PBPhotoUsage)usage
            resultBlock:(void(^)(int resultCode))resultBlock
{
    PPDebug(@"<deleteUserPhoto> userPhotoId = %@", userPhotoId);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest deleteUserPhoto:SERVER_URL
                                                                    appId:appId
                                                                   userId:userId
                                                              userPhotoId:userPhotoId
                                                                    usage:usage];
        
        //        PPDebug(@"<actionSaveOpus> opusId=%@, action=%@, resultCode=%d",
        //                opusId, actionName, output.resultCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

@end
