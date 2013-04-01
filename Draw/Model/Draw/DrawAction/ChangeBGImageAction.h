//
//  ChangeBGImageAction.h
//  Draw
//
//  Created by gamy on 13-4-1.
//
//

#import "DrawAction.h"

@interface ChangeBGImageAction : DrawAction

@property(nonatomic, retain)PBDrawBg *drawBg;

- (id)initWithDrawBg:(PBDrawBg *)drawBg;

@end
