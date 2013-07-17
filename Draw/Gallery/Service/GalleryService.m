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
#import "UserManager.h"
#import "Photo.pb.h"
#import "GameMessage.pb.h"

#define TAG_SEP @"$$$"

@implementation GalleryService

SYNTHESIZE_SINGLETON_FOR_CLASS(GalleryService)

- (NSString*)tagArrayStringBySet:(NSSet*)tagSet
{
    NSString* str = @"";
    
//    return @"tag1^tag2^tag3";
    for (NSString* tag in tagSet) {
        if (str.length == 0) {
            str = tag;
        } else {
            str = [NSString stringWithFormat:@"%@%@%@",str, TAG_SEP, tag];
        }
        
    }
    return str;
}

- (void)addUserPhoto:(NSString*)photoUrl
                name:(NSString*)name
              tagSet:(NSSet*)tagSet
               usage:(PBPhotoUsage)usage
               width:(float)width
              heithg:(float)height
         resultBlock:(void(^)(int resultCode, PBUserPhoto* photo))resultBlock
{
    PPDebug(@"<addUserPhoto> favor image %@ with name %@ ,tag %@", photoUrl, name, [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
//    NSString* appId = [ConfigManager appId];
    
    PBUserPhoto_Builder* builder = [PBUserPhoto builder];    
    [builder setName:name];
    [builder setUrl:photoUrl];
    [builder setUserId:userId];
    [builder setCreateDate:time(0)];
    [builder setWidth:width];
    [builder setHeight:height];
    for (NSString* tag in tagSet) {
        [builder addTags:tag];
    }
    [builder setUsage:usage];
    
    PBUserPhoto* photo = [builder build];
    
    dispatch_async(workingQueue, ^{
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerPostAndResponsePB:METHOD_ADD_USER_PHOTO
                                                                          parameters:nil
                                                                            postData:[photo data]];
        
        NSInteger resultCode = output.resultCode;
        PBUserPhoto *resultPhoto = nil;
        if (resultCode == ERROR_SUCCESS){
            resultPhoto = output.pbResponse.userPhoto;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, resultCode, resultPhoto);
        });
        
        /*
        CommonNetworkOutput* output = [GameNetworkRequest addUserPhoto:SERVER_URL
                                                                 appId:appId
                                                                userId:userId
                                                                  data:[photo data]];
        
        NSInteger resultCode = output.resultCode;
        PBUserPhoto *resultPhoto = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            resultPhoto = response.userPhoto;
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, resultCode, resultPhoto);
        });
         */
    });
}

- (void)getUserPhotoWithTagSet:(NSSet*)tagSet
                         usage:(PBPhotoUsage)usage
                        offset:(int)offset
                         limit:(int)limit
                   resultBlock:(void(^)(int resultCode, NSArray* resultArray))resultBlock
{
    PPDebug(@"<getUserPhotoWithTagSet> get image with tag %@,offset = %d, limit = %d", [tagSet description], offset, limit);
    
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
        
        NSInteger resultCode = output.resultCode;
        NSArray *list = nil;
        
        @try {
            if (resultCode == 0 && output.responseData != nil){
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                if (response.resultCode == 0){
                    list = [response userPhotoListList];
                }
                else{
                    resultCode = response.resultCode;
                }
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<%s>exception = %@", __FUNCTION__, [exception debugDescription]);
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        @finally {
            
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, resultCode, list);
        });
    });
}

- (void)updateUserPhoto:(NSString*)userPhotoId
               photoUrl:(NSString*)photoUrl
                   name:(NSString*)name
                 tagSet:(NSSet*)tagSet
                  usage:(PBPhotoUsage)usage
             protoPhoto:(PBUserPhoto*)protoPhoto
            resultBlock:(void(^)(int resultCode, PBUserPhoto* photo))resultBlock
{
    PPDebug(@"<updateUserPhoto> userPhotoId = %@,  url = %@ with name %@ ,tag %@", userPhotoId, photoUrl, name, [tagSet description]);
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* appId = [ConfigManager appId];
//    NSString* tagArrayString = [self tagArrayStringBySet:tagSet];
    
    PBUserPhoto_Builder* builder = [PBUserPhoto builderWithPrototype:protoPhoto];
    
    [builder setName:name];
    [builder setUrl:photoUrl];
    [builder setUserId:userId];
    [builder setUserPhotoId:userPhotoId];
    [builder setUsage:usage];
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
        PBUserPhoto *resultPhoto = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            resultPhoto = response.userPhoto;
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, resultCode, resultPhoto);
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
