//
//  SingHotCell.m
//  Draw
//
//  Created by 王 小涛 on 13-10-21.
//
//

#import "SingHotCell.h"
#import "AutoCreateViewByXib.h"

@implementation SingHotCell




@end

@implementation OpusCell

AUTO_CREATE_VIEW_BY_XIB(OpusCell);

//+ (id)createWithOpus:()

- (void)dealloc {
    [_opusImageView release];
    [super dealloc];
}

@end
