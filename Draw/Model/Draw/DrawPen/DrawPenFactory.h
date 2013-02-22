//
//  DrawPenFactory.h
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "DrawPenProtocol.h"

typedef enum{
    DrawPenTypeDash = 1000,
    DrawPenTypeBlur,
    DrawPenTypeMark,
}DrawPenType;


//Pencil = 1000,
//WaterPen,
//Pen,
//IcePen,
//Quill,
//PenCount,


@interface DrawPenFactory : NSObject

+ (id<DrawPenProtocol>)createDrawPen:(DrawPenType)type;

@end

