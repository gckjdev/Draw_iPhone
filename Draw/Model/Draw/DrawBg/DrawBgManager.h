//
//  DrawBgManager.h
//  Draw
//
//  Created by gamy on 13-3-2.
//
//

#import <Foundation/Foundation.h>
#import "Draw.pb.h"
#import "SDWebImageManager.h"

@class StorageManager;

typedef enum{
    
    ShowStyleCenter = 0,
    ShowStylePattern,
    
}ShowStyle;



@interface DrawBgManager : NSObject

@property (nonatomic, retain) StorageManager *imageManager;

+ (id)defaultManager;
//+ (void )imageForRemoteURL:(NSString *)url success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;

- (PBDrawBg *)pbDrawBgWithId:(NSString *)drawBgId;
- (NSString *)baseDir;
- (NSArray *)pbDrawBgGroupList;

//Test Code
+ (void)createTestData:(NSUInteger)number;
+ (void)scaleImages;

- (NSString*)downloadProgressNotificationName;

- (BOOL)saveImage:(UIImage*)image forKey:(NSString*)key;
- (BOOL)saveData:(NSData*)data forKey:(NSString*)key;
- (UIImage*)imageForKey:(NSString*)key;
- (BOOL)isImageExists:(NSString*)key;

@end


@interface PBDrawBg(Ext)

- (UIImage *)localImage;
- (NSString *)localThumbUrl;
- (UIImage *)localThumb;
- (NSURL *)remoteURL;


@end
