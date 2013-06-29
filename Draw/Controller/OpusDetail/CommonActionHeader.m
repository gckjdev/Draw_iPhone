//
//  CommonActionHeader.m
//  Draw
//
//  Created by 王 小涛 on 13-6-9.
//
//

#import "CommonActionHeader.h"

@implementation CommonActionHeader

- (IBAction)clickActionButton:(id)sender{
    if ([_delegate respondsToSelector:@selector(didClickActionButton:)]) {
        [_delegate didClickActionButton:sender];
    }
}

@end
