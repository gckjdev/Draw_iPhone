//
//  OpusClassInfo.h
//  Draw
//
//  Created by qqn_pipi on 14-6-5.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@interface OpusClassInfo : NSObject

@property (nonatomic,retain) PBClassBuilder* pbOpusClassBuilder;

@property (nonatomic, retain) OpusClassInfo* parentClassInfo;
@property (nonatomic, retain) NSMutableArray* subClassList;

+ (id) objectWithDictionary:(NSDictionary*)dictionary;
- (id) initWithDictionary:(NSDictionary*)dictionary;

+ (PBClass*)createPBClass:(NSString*)classId;
- (NSString*)classId;
- (NSString*)name;
- (void)clearSubClasses;

- (NSString*)title;     // for display

@end
