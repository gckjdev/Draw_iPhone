//
//  ShapeGroup.h
//  Draw
//
//  Created by gamy on 13-6-12.
//
//


//This class is only used to crate shape group data

#import "ShapeInfo.h"
#import "ItemType.h"
#import "GameBasic.pb.h"
#import "Draw.pb.h"
#import <Foundation/Foundation.h>

#define ImageShapeTypeStart(x)  ShapeTypeImage##x##Start
#define ImageShapeTypeEnd(x)  ShapeTypeImage##x##End

#define IsImageShapeType(type, value) ((value >= ImageShapeTypeStart(type)) && (value <= ImageShapeTypeEnd(type)))


#define INTERFACE(group) \
@interface group##Group : ShapeGroup\
@end


@interface ShapeGroup : NSObject

//override

+ (NSArray *)localizeNameListWithENName:(NSString *)en CNName:(NSString *)cn;

- (ShapeType *)shapeTypeList;
//- (NSString *)shapeFileNamePrefix;
- (NSArray *)shapeNameList;
- (ItemType)groupId;

// not override
- (PBImageShapeGroup *)toPBShapeGroup;

@end

INTERFACE(Basic0)

INTERFACE(Animal0)
INTERFACE(Animal1)

INTERFACE(Nature0)
INTERFACE(Nature1)

INTERFACE(Shape0)
INTERFACE(Shape1)

INTERFACE(Sign0)
INTERFACE(Sign1)

INTERFACE(Stuff0)
INTERFACE(Stuff1)

INTERFACE(Plant0)
INTERFACE(Plant1)
INTERFACE(Plant2)

