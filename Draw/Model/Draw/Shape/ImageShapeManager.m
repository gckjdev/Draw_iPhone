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

+ (NSString *)svgFileNameWithType:(ShapeType)type
{
    NSInteger index = type % TYPE_MOD_VALUE;
    NSString *typeName = nil;
    if (IsImageShapeType(Animal, type)) {
        typeName = @"animal";
    }else if(IsImageShapeType(Nature, type)){
        typeName = @"nature";
    }else if(IsImageShapeType(Plant, type)){
        typeName = @"plant";
    }else if(IsImageShapeType(Sign, type)){
        typeName = @"sign";
    }else if(IsImageShapeType(Stuff, type)){
        typeName = @"stuff";
    }else if(IsImageShapeType(Shape, type)){
        typeName = @"shape";
    }else{
        return nil;
    }
    return [NSString stringWithFormat:@"%@_%d",typeName, index];
}

+ (NSString *)fullPathWithSvgFileName:(NSString *)fileName
{
    if ([fileName length] == 0) {
        return nil;
    }
    //TODO construct the full path
    return fileName;
}

+ (ImageShapeInfo *)imageShapeWithType:(ShapeType)type
{
    
    if (_bezierPathDict == nil) {
        _bezierPathDict = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [NSString stringWithFormat:@"%d",type];
    UIBezierPath *bPath = [_bezierPathDict objectForKey:key];
    if (bPath == nil) {
        NSString *name = [ImageShapeManager svgFileNameWithType:type];
        NSString *filePath = [ImageShapeManager fullPathWithSvgFileName:name];
        
        if ([filePath length] != 0) {
            bPath = [PocketSVG bezierPathWithSVGFileNamed:name];
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

+ (void)cleanCache
{
    [_bezierPathDict removeAllObjects];
}


//////////


+ (NSArray *)createArrayWithName:(NSString *)name range:(NSRange)range
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = range.location; i < range.location + range.length; ++ i) {
        NSString *str = [NSString stringWithFormat:@"%@_%d", name, i];
        [array addObject:str];
    }
    return array;
}

//#define CAN(name,loc) [ImageShapeManager createArrayWithName:name range:NSMakeRange(loc, 6)]
//
//+ (NSArray *)nameListForGroup:(ItemType)gid
//{
//    switch (gid) {
//        case ImageShapeAnimal0:
//            return CAN(@"animal", 0);
//        case ImageShapeAnimal1:
//            return CAN(@"animal", 6);
//            
//        case ImageShapeNature0:
//            return CAN(@"nature", 0);
//        case ImageShapeNature1:
//            return CAN(@"nature", 6);
//            
//        case ImageShapeShape0:
//            return CAN(@"shape", 0);
//        case ImageShapeShape1:
//            return CAN(@"shape", 6);
//            
//        case ImageShapeSign0:
//            return CAN(@"sign", 0);
//        case ImageShapeSign1:
//            return CAN(@"sign", 6);
//
//        case ImageShapeStuff0:
//            return CAN(@"stuff", 0);
//        case ImageShapeStuff1:
//            return CAN(@"stuff", 6);
//            
//        case ImageShapePlant0:
//            return CAN(@"plant", 0);
//        case ImageShapePlant1:
//            return CAN(@"plant", 6);
//        case ImageShapePlant2:
//            return CAN(@"plant", 12);
//            
//            
//        default:
//            return nil;
//    }
//    
//}


//+ (ShapeType *)shapeTypeListForGroup:(ItemType)gid
//{
//    switch (gid) {
//            
//        case ImageShapeAnimal0:
//            GetShapeTypeList(Animal, 0);
//        case ImageShapeAnimal1:
//            GetShapeTypeList(Animal, 6);
//            
//        case ImageShapeNature0:
//            GetShapeTypeList(Nature, 0);
//        case ImageShapeNature1:
//            GetShapeTypeList(Nature, 6);
//            
//        case ImageShapeShape0:
//            GetShapeTypeList(Shape, 0);
//        case ImageShapeShape1:
//            GetShapeTypeList(Shape, 6);
//            
//        case ImageShapeSign0:
//            GetShapeTypeList(Shape, 0);
//        case ImageShapeSign1:
//            GetShapeTypeList(Shape, 6);
//            
//        case ImageShapeStuff0:
//            GetShapeTypeList(Shape, 0);
//        case ImageShapeStuff1:
//            GetShapeTypeList(Shape, 6);
//            
//        case ImageShapePlant0:
//            GetShapeTypeList(Plant, 0);
//        case ImageShapePlant1:
//            GetShapeTypeList(Plant, 6); 
//        case ImageShapePlant2:
//            GetShapeTypeList(Plant, 12);
//            
//        default:
//            return nil;
//    }
//}



+ (PBImageShapeGroup *)createGroupWithGroupId:(ItemType)gid
                                         name:(NSString *)name
                                        count:(NSInteger)count
{
    

    
//    PBImageShapeGroup_Builder *builder = [[PBImageShapeGroup_Builder alloc] init];
//    
//    [builder setGroupId:gid];
//    [builder setGroupName:name];
//    
//    return [builder build];
}


#define BUILD_GROUP(group)  [builder addImageShapeGroup:[[[[group##Group alloc] init] autorelease] toPBShapeGroup]];

+ (void)createMetaFile
{
    PBImageShapeGroupMeta_Builder *builder = [[[PBImageShapeGroupMeta_Builder alloc] init] autorelease];
    
    BUILD_GROUP(Animal0)
    BUILD_GROUP(Animal1)
    
    BUILD_GROUP(Nature0)
    BUILD_GROUP(Nature1)
    
    BUILD_GROUP(Shape0)
    BUILD_GROUP(Shape1)
    
    BUILD_GROUP(Sign0)
    BUILD_GROUP(Sign1)
    
    BUILD_GROUP(Stuff0)
    BUILD_GROUP(Stuff1)
    
    BUILD_GROUP(Plant0)
    BUILD_GROUP(Plant1)
    BUILD_GROUP(Plant2)
    
    NSData *data = [[builder autorelease] data];
    [data writeToFile:@"/Users/qqn_pipi/tool/shape.txt" atomically:YES];
}

@end
