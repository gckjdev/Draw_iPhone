//
//  PaintAction.h
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "DrawAction.h"
#import "Paint.h"

@interface PaintAction : DrawAction
{
    
}
@property(nonatomic, retain)Paint *paint;
+ (id)paintActionWithPaint:(Paint *)paint;
@end
