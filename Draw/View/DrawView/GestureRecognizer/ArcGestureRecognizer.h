//
//  ArcGestureRecognizer.h
//  SourceProfile
//
//  Created by gamy on 13-3-11.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface ArcGestureRecognizer : UIGestureRecognizer
{
    
}

@property(nonatomic, assign, readonly) CGFloat radian;
@property(nonatomic, assign, readonly) BOOL direction;

@property(nonatomic, assign)BOOL forceCircle;

@end

extern CGFloat CGPointDistance(CGPoint p1, CGPoint p2);