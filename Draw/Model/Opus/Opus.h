//
//  Opus.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>
#import "Opus.pb.h"
#import "BuriSerialization.h"

typedef enum _OpusCategory{
    OpusCategoryDraw = 1,
    OpusCategorySing = 2,
    OpusCategoryAskPs = 3,
    OpusCategoryAskPsOpus = 4
}OpusCategory;

@interface Opus : NSObject <BuriSupport>

@property (nonatomic, retain) PBOpus_Builder* pbOpusBuilder;

+ (id)opusWithCategory:(OpusCategory)category;
+ (id)opusWithPBOpus:(PBOpus *)pbOpus;

- (void)setType:(PBOpusType)type;
- (void)setName:(NSString *)name;  
- (void)setDesc:(NSString *)desc;
- (void)setTargetUser:(PBGameUser *)user;

- (PBOpus *)pbOpus;
- (NSData *)data;

@end

