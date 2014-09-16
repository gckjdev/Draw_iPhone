//
//  BrushAction.h
//  Draw
//
//  Created by 黄毅超 on 14-9-1.
//
//

#import "DrawAction.h"
#import "BrushStroke.h"

@interface BrushAction : DrawAction

@property (nonatomic, retain) BrushStroke *brushStroke;

+ (id)brushActionWithBrushStroke:(BrushStroke *)brushStroke;

- (void)addPoint:(CGPoint)point
           width:(float)width
          inRect:(CGRect)rect
         forShow:(BOOL)forShow;

@end
