//
//  SettingAction.h
//  Draw
//
//  Created by gamy on 13-6-5.
//
//

#import "DrawAction.h"
#import "PathConstructor.h"

//typedef enum{
//    
//    ClipTypeRectangle = 1,
//    ClipTypeEllipse = 2,
//    ClipTypePolygon = 3,
//    ClipTypePath = 4,
//    
//}ClipType;

@interface SettingAction : DrawAction

@property(nonatomic, assign)NSInteger tag;
@property(nonatomic, assign)PathConstructType clipType;



@end


@interface ClipStartAction : SettingAction
{
    
}
- (CGPathRef)clipPath;

@end


@interface ClipEndAction : SettingAction



@end