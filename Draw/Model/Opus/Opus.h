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

typedef enum _OpusType{
    OpusTypeDraw = 1,
    OpusTypeSing = 2
}OpusType;

@interface Opus : NSObject <BuriSupport>

@property (nonatomic, copy) NSString *opusKey;
@property (nonatomic, retain) PBOpus_Builder* pbOpusBuilder;

+ (id)opusWithType:(OpusType)type;
+ (id)opusWithPBOpus:(PBOpus *)pbOpus;

- (void)setAim:(PBOpusAim)aim;
- (void)setName:(NSString *)name;  
- (void)setDesc:(NSString *)desc;
- (void)setTargetUser:(PBGameUser *)user;

- (PBOpus *)pbOpus;

+ (Class)classForOpusKey:(NSString *)opusKey;

@end

