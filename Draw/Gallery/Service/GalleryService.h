//
//  GalleryService.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "CommonService.h"

@interface GalleryService : CommonService

+ (GalleryService*)defaultService;
- (void)addUserPhoto:(NSString*)photoUrl
                name:(NSString*)name
              tagSet:(NSSet*)tagSet
         resultBlock:(void(^)(int resultCode))resultBlock;
- (void)getUserPhotoWithTagSet:(NSSet*)tagSet
                        offset:(int)offset
                         limit:(int)limit
                   resultBlock:(void(^)(int resultCode, NSArray* resultArray))resultBlock;
- (void)updateUserPhoto:(NSString*)photoId
               photoUrl:(NSString*)photoUrl
                   name:(NSString*)name
                 tagSet:(NSSet*)tagSet
            resultBlock:(void(^)(int resultCode))resultBlock;
- (void)deleteUserPhoto:(NSString*)photoId
            resultBlock:(void(^)(int resultCode))resultBlock;
@end