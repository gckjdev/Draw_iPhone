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
- (void)favorImage:(NSString*)url
              name:(NSString*)name
            tagSet:(NSSet*)tagSet
       resultBlock:(void(^)(int resultCode))resultBlock;
- (void)getGalleryImageWithTagSet:(NSSet*)tagSet
                      resultBlock:(void(^)(int resultCode, NSArray* resultArray))resultBlock;

@end