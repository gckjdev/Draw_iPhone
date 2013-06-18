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

IMPLEMENTE(Basic0,ImageShapeBasic0,Basic,0,@"Basic", @"基本")

IMPLEMENTE(Animal0,ImageShapeAnimal0,Animal,0,@"Bird", @"飞禽")

IMPLEMENTE(Animal1,ImageShapeAnimal1,Animal,6,@"Animal", @"走兽")

IMPLEMENTE(Nature0,ImageShapeNature0,Nature,0,@"Snow", @"雨雪")
IMPLEMENTE(Nature1,ImageShapeNature1,Nature,6,@"Sun", @"日月")

//
IMPLEMENTE(Shape0,ImageShapeShape0,Shape,0,@"Corner", @"棱角")
IMPLEMENTE(Shape1,ImageShapeShape1,Shape,6,@"Arc", @"圆弧")

IMPLEMENTE(Sign0,ImageShapeSign0,Sign,0,@"Stuff", @"家具")
IMPLEMENTE(Sign1,ImageShapeSign1,Sign,6,@"Travel", @"出行")

IMPLEMENTE(Stuff0,ImageShapeStuff0,Stuff,0,@"Math", @"算术")
IMPLEMENTE(Stuff1,ImageShapeStuff1,Stuff,6,@"Music", @"玄音")

IMPLEMENTE(Plant0,ImageShapePlant0,Plant,0,@"Grass", @"芳草")
IMPLEMENTE(Plant1,ImageShapePlant1,Plant,6,@"Leaf", @"落木")
IMPLEMENTE(Plant2,ImageShapePlant2,Plant,12,@"Flower", @"羞花")


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
