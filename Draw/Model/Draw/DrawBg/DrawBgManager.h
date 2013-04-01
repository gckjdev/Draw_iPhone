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


typedef enum{
    
    ShowStyleCenter = 0,
    ShowStylePattern,
    
}ShowStyle;



@interface DrawBgManager : NSObject


+ (id)defaultManager;
+ (void )imageForRemoteURL:(NSString *)url success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;

- (PBDrawBg *)pbDrawBgWithId:(NSString *)drawBgId;
- (NSString *)baseDir;
- (NSArray *)pbDrawBgGroupList;

//Test Code
+ (void)createTestData:(NSUInteger)number;

@end


@interface PBDrawBg(Ext)

- (UIImage *)localImage;

- (NSURL *)remoteURL;


@end
