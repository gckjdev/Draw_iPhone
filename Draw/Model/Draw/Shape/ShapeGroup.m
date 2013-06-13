//
//  ShapeGroup.m
//  Draw
//
//  Created by gamy on 13-6-12.
//
//

#define GetShapeTypeList(type,loc) {\
static ShapeType type##List[] = {\
ImageShapeTypeStart(type)+loc,\
ImageShapeTypeStart(type)+loc+1,\
ImageShapeTypeStart(type)+loc+2,\
ImageShapeTypeStart(type)+loc+3,\
ImageShapeTypeStart(type)+loc+4,\
ImageShapeTypeStart(type)+loc+5,\
ShapeTypeNone\
};\
return type##List;}

#import "ShapeGroup.h"

@implementation ShapeGroup

+ (NSArray *)localizeNameListWithENName:(NSString *)en CNName:(NSString *)cn
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    PBLocalizeString_Builder *builder = [[[PBLocalizeString_Builder alloc] init] autorelease];
    [builder setLanguageCode:@"en"];
    [builder setLocalizedText:en];
    [builder setText:en];
    [array addObject:[builder build]];
    
    
     builder = [[[PBLocalizeString_Builder alloc] init] autorelease];
    [builder setLanguageCode:@"zh_Hans"];
    [builder setLocalizedText:cn];
    [builder setText:en]; 
    [array addObject:[builder build]];

    return array;
    
}

- (ShapeType *)shapeTypeList
{
    return NULL;
}
- (NSArray *)shapeNameList
{
    return nil;
}
- (ItemType)groupId
{
    return ItemTypeNo;
}

- (PBImageShapeGroup *)toPBShapeGroup
{
    PBImageShapeGroup_Builder *builder = [[[PBImageShapeGroup_Builder alloc] init] autorelease];
    [builder setGroupId:[self groupId]];
    [builder addAllGroupName:[self shapeNameList]];

    ShapeType *type = [self shapeTypeList];
    while (type != NULL && (*type) != ShapeTypeNone) {
        [builder addShapeType:*type];
        type = type + 1;
    }    
    PBImageShapeGroup *group = [builder build];
    return group;

}

@end



#define IMPLEMENTE(group, gid, type, loc, en, cn) \
@implementation group##Group\
\
- (ShapeType *)shapeTypeList\
{\
    GetShapeTypeList(type, loc);\
}\
- (NSArray *)shapeNameList\
{\
    return [ShapeGroup localizeNameListWithENName:en CNName:cn];\
}\
- (ItemType)groupId\
{\
    return gid;\
}\
\
@end


IMPLEMENTE(Animal0,ImageShapeAnimal0,Animal,0,@"Aniaml 1", @"动物1")

IMPLEMENTE(Animal1,ImageShapeAnimal1,Animal,6,@"Aniaml 2", @"动物2")

IMPLEMENTE(Nature0,ImageShapeNature0,Nature,0,@"Nature 1", @"自然1")
IMPLEMENTE(Nature1,ImageShapeNature1,Nature,6,@"Nature 2", @"自然2")

//
IMPLEMENTE(Shape0,ImageShapeShape0,Shape,0,@"Shape 1", @"形状1")
IMPLEMENTE(Shape1,ImageShapeShape1,Shape,6,@"Shape 2", @"形状2")

IMPLEMENTE(Sign0,ImageShapeSign0,Sign,0,@"Sign 1", @"标记1")
IMPLEMENTE(Sign1,ImageShapeSign1,Sign,6,@"Sign 2", @"标记2")

IMPLEMENTE(Stuff0,ImageShapeStuff0,Stuff,0,@"Stuff 1", @"材料1")
IMPLEMENTE(Stuff1,ImageShapeStuff1,Stuff,6,@"Stuff 2", @"材料2")

IMPLEMENTE(Plant0,ImageShapePlant0,Plant,0,@"Plant 1", @"植物1")
IMPLEMENTE(Plant1,ImageShapePlant1,Plant,6,@"Plant 2", @"植物2")
IMPLEMENTE(Plant2,ImageShapePlant2,Plant,12,@"Plant 3", @"植物3")


/*
@implementation Animal1Group

- (ShapeType *)shapeTypeList
{
    GetShapeTypeList(type, loc)
}
- (NSArray *)shapeNameList
{
    return [ShapeGroup localizeNameListWithENName:en CNName:cn];
}
- (ItemType)groupId
{
    return gid;
}

@end
*/
