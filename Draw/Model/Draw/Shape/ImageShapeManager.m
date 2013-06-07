//
//  ImageShapeManager.m
//  Draw
//
//  Created by gamy on 13-6-7.
//
//

#import "ImageShapeManager.h"
#import "PocketSVG.h"


#define ImageShapeTypeStart(x)  ShapeTypeImage##x##Start
#define ImageShapeTypeEnd(x)  ShapeTypeImage##x##End

#define IsImageShapeType(type, value) ((value >= ImageShapeTypeStart(type)) && (value <= ImageShapeTypeEnd(type)))


NSMutableDictionary *_imageShapeDict;

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
    
    if (_imageShapeDict == nil) {
        _imageShapeDict = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [NSString stringWithFormat:@"%d",type];
    ImageShapeInfo *shape = [_imageShapeDict objectForKey:key];
    if (shape) {
        return shape;
    }
    NSString *name = [ImageShapeManager svgFileNameWithType:type];
    NSString *filePath = [ImageShapeManager fullPathWithSvgFileName:name];
    if ([filePath length] != 0) {
        CGPathRef  path = [PocketSVG bezierPathWithSVGFilePath:filePath].CGPath;
        if (path != NULL) {
            ImageShapeInfo *shapeInfo = [[[ImageShapeInfo alloc] initWithCGPath:path] autorelease];
            [_imageShapeDict setObject:shapeInfo forKey:key];
            shapeInfo.type = type;
            return shapeInfo;
            
        }
    }
    return nil;
}

+ (void)cleanCache
{
    [_imageShapeDict removeAllObjects];
}

@end
