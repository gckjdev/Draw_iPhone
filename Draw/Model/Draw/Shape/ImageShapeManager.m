//
//  ImageShapeManager.m
//  Draw
//
//  Created by gamy on 13-6-7.
//
//

#import "ImageShapeManager.h"
#import "PocketSVG.h"
#import "Draw.pb.h"
#import "ItemType.h"
#import "ShapeGroup.h"

NSMutableDictionary *_bezierPathDict;

@implementation ImageShapeManager


#define TYPE_MOD_VALUE 100


- (NSString *)fullPathWithShapeType:(ShapeType)type
{
    NSString *name = [NSString stringWithFormat:@"%d",type];
    //TODO construct full path;
    return name;
}

- (ImageShapeInfo *)imageShapeWithType:(ShapeType)type
{
    
    if (_bezierPathDict == nil) {
        _bezierPathDict = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [NSString stringWithFormat:@"%d",type];
    UIBezierPath *bPath = [_bezierPathDict objectForKey:key];
    if (bPath == nil) {
        NSString *filePath = [self fullPathWithShapeType:type];
        if ([filePath length] != 0) {
            bPath = [PocketSVG bezierPathWithSVGFilePath:filePath];
            if (bPath) {
                [_bezierPathDict setObject:bPath forKey:key];
            }
        }
    }
    if (bPath != nil) {
        ImageShapeInfo *shapeInfo = [[[ImageShapeInfo alloc] initWithCGPath:bPath.CGPath] autorelease];
        shapeInfo.type = type;
        return shapeInfo;
        
    }


    return nil;
}

- (void)cleanCache
{
    [_bezierPathDict removeAllObjects];
}


//////////


+ (void)printShapeGroup:(PBImageShapeGroup *)group
{
    PPDebug(@"===PRINT GROUP START===");
    //group id
    PPDebug(@"GROUP ID = %d;\n", group.groupId);
    
    //name
    PPDebug(@"LOCALE NAME LIST = [");
    for (PBLocalizeString *lString in group.groupNameList) {
        PPDebug(@"%@ = %@",lString.languageCode,lString.localizedText);
    }
    PPDebug(@"];\n");
    
    //type list
//    PPDebug(@"");
    NSString *string = @"";
    for (NSNumber *type in group.shapeTypeList) {
        if ([string length] > 0) {
            string = [NSString stringWithFormat:@"%@, %d",string, type.integerValue];
        }else{
            string = [NSString stringWithFormat:@"%d",type.integerValue];
        }

    }
    PPDebug(@"TYPE LIST = [%@];\n",string);

    PPDebug(@"===PRINT GROUP STOP ===\n");
    
}

#define BUILD_GROUP(group)  [builder addImageShapeGroup:[[[[group##Group alloc] init] autorelease] toPBShapeGroup]];
#define PRINT_GROUP(group) [ImageShapeManager printShapeGroup:group]


+ (void)loadMetaFile
{
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/qqn_pipi/tool/shape_group_meta.pb"];
    PBImageShapeGroupMeta *meta = [PBImageShapeGroupMeta parseFromData:data];
    
    for (PBImageShapeGroup *group in meta.imageShapeGroupList) {
        PRINT_GROUP(group);
    }
    
}

+ (void)createMetaFile
{
    PBImageShapeGroupMeta_Builder *builder = [[[PBImageShapeGroupMeta_Builder alloc] init] autorelease];
    
    BUILD_GROUP(Nature0)
    BUILD_GROUP(Nature1)

    BUILD_GROUP(Animal0)
    BUILD_GROUP(Animal1)
    
    BUILD_GROUP(Shape0)
    BUILD_GROUP(Shape1)
    
    BUILD_GROUP(Stuff0)
    BUILD_GROUP(Stuff1)

    BUILD_GROUP(Sign0)
    BUILD_GROUP(Sign1)
    
    BUILD_GROUP(Plant0)
    BUILD_GROUP(Plant1)
    BUILD_GROUP(Plant2)
    
    NSData *data = [[builder build] data];
    [data writeToFile:@"/Users/qqn_pipi/tool/shape_group_meta.pb" atomically:YES];
}

@end
