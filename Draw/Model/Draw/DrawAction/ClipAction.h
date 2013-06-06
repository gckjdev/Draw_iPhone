//
//  SettingAction.h
//  Draw
//
//  Created by gamy on 13-6-5.
//
//

#import "DrawAction.h"
#import "PathConstructor.h"



@interface ClipAction : DrawAction
{
    BOOL _hasClipContext;
    BOOL _hasUnClipContext;
}

@property(nonatomic, assign)NSInteger clipTag;
@property(nonatomic, assign)PathConstructType clipType;

- (void)clipContext:(CGContextRef)context; //execute once.
- (void)unClipContext:(CGContextRef)context;
@end

