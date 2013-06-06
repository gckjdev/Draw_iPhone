//
//  GalleryManager.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import <Foundation/Foundation.h>
@class GalleryPicture;
@interface GalleryManager : NSObject

+ (GalleryManager*)defaultManager;

- (void)storeGalleryPicture:(GalleryPicture*)picture forKey:(NSString*)key;
- (GalleryPicture*)galleryPictureForKey:(NSString*)key;
- (NSArray*)allGalleryPictures;

@end
