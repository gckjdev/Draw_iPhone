//
//  GalleryManager.m
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "GalleryManager.h"
#import "GalleryPicture.h"
#import "SynthesizeSingleton.h"
#import "ImageSearchResult.h"
#import "StorageManager.h"

#define GALLERY @"gallery"

@implementation GalleryManager

SYNTHESIZE_SINGLETON_FOR_CLASS(GalleryManager)

- (void)storeGalleryPicture:(GalleryPicture*)picture forKey:(NSString*)key
{
    
}
- (GalleryPicture*)galleryPictureForKey:(NSString*)key
{
    return nil;
}
- (NSArray*)allGalleryPictures
{
    return nil;
}

- (void)favorSearchResult:(ImageSearchResult*)searchResult finishBlock:(void(^)(void))block
{
//    StorageManager* manager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:@"gallery"] autorelease];
    
    PPDebug(@"save image %@", searchResult.url);
    
}


@end
