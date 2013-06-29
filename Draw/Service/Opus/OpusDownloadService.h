//
//  OpusDownloadService.h
//  Draw
//
//  Created by 王 小涛 on 13-6-24.
//
//

#import <Foundation/Foundation.h>

@interface OpusDownloadService : NSObject

+ (id)defaultService;

- (NSString *)downloadFileSynchronous:(NSString *)fileUrl
                              destDir:(NSString*)destDir
                     progressDelegate:(id)progressDelegate;

@end
