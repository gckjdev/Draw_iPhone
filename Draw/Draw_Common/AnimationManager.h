//
//  AnimationManager.h
//  Draw
//
//  Created by  on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface AnimationManager : NSObject
{
    
}

+ (void)popUpView:(UIView *)view 
     fromPosition:(CGPoint)fromPosition 
       toPosition:(CGPoint)toPosition
         interval:(NSTimeInterval)interval
         delegate:(id)delegate;
@end
