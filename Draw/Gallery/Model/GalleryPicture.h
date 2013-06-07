//
//  GalleryPicture.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import <Foundation/Foundation.h>

@interface GalleryPicture : NSObject

@property (retain, nonatomic) NSDate* createDate;
@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSArray* tagArray;
@property (retain, nonatomic) NSString* imageUrl;

- (id)initWithImageUrl:(NSString*)imageUrl
                  name:(NSString*)name
              tagArray:(NSArray*)tagArray;

@end
