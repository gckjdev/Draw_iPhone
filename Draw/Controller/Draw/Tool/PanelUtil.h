//
//  DrawToolType.h
//  Draw
//
//  Created by gamy on 13-8-20.
//
//

#import <Foundation/Foundation.h>


typedef enum{
    DrawToolTypeSize = 0,
    DrawToolTypeBG,
    DrawToolTypeCopy,
    DrawToolTypeDesc,
    DrawToolTypeDrawTo,
    DrawToolTypeGrid,
    DrawToolTypeHelp,
    DrawToolTypeSubject,
    DrawToolTypeNumber
    
}DrawToolType;

@interface PanelUtil : NSObject

+ (UIImage *)imageForType:(DrawToolType)type;
+ (NSString *)titleForType:(DrawToolType)type;

@end
