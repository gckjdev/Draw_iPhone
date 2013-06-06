//
//  GalleryPicture.m
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "GalleryPicture.h"
#import "ImageSearchResult.h"

@implementation GalleryPicture

- (id)initWithImageUrl:(NSString *)imageUrl
                  name:(NSString *)name
              tagArray:(NSArray *)tagArray
{
    self = [super init];
    if (self) {
        self.name = name;
        self.createDate = [NSDate dateWithTimeIntervalSinceNow:0];
        self.tagArray = tagArray;
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_createDate release];
    [_tagArray release];
    [_imageUrl release];
    [super dealloc];
}

@end
