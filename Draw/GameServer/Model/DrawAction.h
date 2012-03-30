//
//  DrawAction.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Paint;

typedef enum {
    
    DRAW_ACTION_TYPE_DRAW,
    DRAW_ACTION_TYPE_CLEAN
} DRAW_ACTION_TYPE;

@interface DrawAction : NSObject {
    
}

@property (nonatomic, assign) DRAW_ACTION_TYPE type;
@property (nonatomic, retain) Paint *paint;

- (id)initWithType:(DRAW_ACTION_TYPE)aType paint:(Paint*)aPaint ;

@end
