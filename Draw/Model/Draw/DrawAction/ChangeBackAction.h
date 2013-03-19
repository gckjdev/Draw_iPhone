//
//  ChangeBackAction.h
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "DrawAction.h"

@interface ChangeBackAction : DrawAction

- (DrawColor *)color;
- (id)initWithColor:(DrawColor *)color;
@end
