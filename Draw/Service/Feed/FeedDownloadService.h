//
//  FeedDownloadService.h
//  Draw
//
//  Created by qqn_pipi on 13-3-5.
//
//

#import <Foundation/Foundation.h>

@interface FeedDownloadService : NSObject

+ (FeedDownloadService*)defaultService;


// Download Draw ZIP Data File, Unzip Data and return NSData of File
// fileURL is file HTTP Remote URL
// fileName is the Draw Feed ID
- (NSData*)downloadDrawDataFile:(NSString*)fileURL
                       fileName:(NSString*)fileName
       downloadProgressDelegate:(id)downloadProgressDelegate;

@end
