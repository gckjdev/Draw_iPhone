//
//  DrawToolType.h
//  Draw
//
//  Created by gamy on 13-8-20.
//
//

#import <Foundation/Foundation.h>

#define KEY(x) (@(x))

typedef enum{
    //up
    DrawToolTypeEnd = -1,
    DrawToolTypeSize = 0,
    DrawToolTypeBG,
    DrawToolTypeCopy,
    DrawToolTypeDesc,
    DrawToolTypeDrawTo,
    DrawToolTypeGrid,
    DrawToolTypeHelp,
    DrawToolTypeSubject,

    //below
    
    DrawToolTypeUndo,
    DrawToolTypeRedo,
    DrawToolTypeSelector,
    DrawToolTypeShadow,
    DrawToolTypeGradient,
    DrawToolTypeShape,
    DrawToolTypeBucket,
    DrawToolTypeCanvaseBG, //called DrawToolTypeBG when used in up panel
    DrawToolTypeBlock, //called DrawToolTypeGrid when used in up panel
    
    //online draw
    DrawToolTypeChat,
    DrawToolTypeTimeset,
    
    //for iphone 5
    DrawToolTypePen,
    DrawToolTypeEraser,
    DrawToolTypePalette,
    DrawToolTypeAddColor,
    
    
    //unused
    DrawToolTypeText,
    DrawToolTypeFX,
    DrawToolTypeStraw,
    DrawToolTypeWidthPicker,

}DrawToolType;

@interface PanelUtil : NSObject

+ (UIImage *)imageForType:(DrawToolType)type;
+ (UIImage *)bgImageForType:(DrawToolType)type
                      state:(UIControlState)state;
+ (NSString *)titleForType:(DrawToolType)type;
+ (DrawToolType *)belowToolList;
+ (DrawToolType *)upToolList;
+ (NSUInteger)numberOfTypeList:(DrawToolType *)types;

+ (NSArray *)xsForTypes:(DrawToolType *)types
                   edge:(CGFloat)edge
                  width:(CGFloat)width
                  start:(CGFloat)start
                 length:(CGFloat)length;

@end
