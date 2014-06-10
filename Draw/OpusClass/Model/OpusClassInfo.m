//
//  OpusClassInfo.m
//  Draw
//
//  Created by qqn_pipi on 14-6-5.
//
//

#import "OpusClassInfo.h"

@implementation OpusClassInfo

- (void) dealloc
{
    PPRelease(_pbOpusClassBuilder);
    PPRelease(_parentClassInfo);
    PPRelease(_subClassList);
    [super dealloc];
}

+ (id) objectWithDictionary:(NSDictionary*)dictionary
{
    id obj = [[[OpusClassInfo alloc] initWithDictionary:dictionary] autorelease];
    return obj;
}

- (id) initWithDictionary:(NSDictionary*)dictionary
{
    self=[super init];
    if(self)
    {
        _subClassList = [[NSMutableArray alloc] init];
        
        _pbOpusClassBuilder = [[PBClass_Builder alloc] init];
        @try {            
            [_pbOpusClassBuilder setClassId:[dictionary objectForKey:@"class_id"]];
            [_pbOpusClassBuilder setCnName:[dictionary objectForKey:@"cn_name"]];
            [_pbOpusClassBuilder setEnName:[dictionary objectForKey:@"en_name"]];
            [_pbOpusClassBuilder setTcnName:[dictionary objectForKey:@"tcn_name"]];
            
            // set sub class, will be replace later
            NSArray* subClassArray = [dictionary objectForKey:@"sub_classes"];
            for (NSString* subClassId in subClassArray){
                [_pbOpusClassBuilder addSubClasses:[OpusClassInfo createPBClass:subClassId]];
            }
            
            // set parent class, will be replaced later
            NSString* parentClassId = [dictionary objectForKey:@"parent_class"];
            if ([parentClassId length] > 0){
                [_pbOpusClassBuilder setParentClass:[OpusClassInfo createPBClass:parentClassId]];
            }            
        }
        @catch (NSException *exception) {
            PPDebug(@"<initWithDictionary> catch exception=%@", [exception description]);
        }
        @finally {
            PPDebug(@"opus class=%@", [_pbOpusClassBuilder classId]);
        }
    }
    return self;
}

+ (PBClass*)createPBClass:(NSString*)classId
{
    PBClass_Builder* subClassBuilder = [[[PBClass_Builder alloc] init] autorelease];
    [subClassBuilder setClassId:classId];
    return [subClassBuilder build];
}

- (NSString*)classId
{
    return _pbOpusClassBuilder.classId;
}

- (void)clearSubClasses
{
    [self.subClassList removeAllObjects];
}

- (NSString*)name
{
    if ([LocaleUtils isChina]){
        return _pbOpusClassBuilder.cnName;
    }
    else if ([LocaleUtils isChinese]){
        return _pbOpusClassBuilder.tcnName;
    }
    else if ([LocaleUtils isEnglish]){
        return _pbOpusClassBuilder.enName;
    }
    else{
        return _pbOpusClassBuilder.cnName;
    }
}

@end
