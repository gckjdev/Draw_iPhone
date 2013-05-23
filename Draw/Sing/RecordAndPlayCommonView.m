//
//  RecordAndPlayCommonView.m
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import "RecordAndPlayCommonView.h"
#import "RecordAndPlayControl.h"

@implementation RecordAndPlayCommonView

- (IBAction)clickControl:(id)sender {
    if ([_control.delegate respondsToSelector:@selector(didClickControl:)]) {
        [_control.delegate didClickControl:_control];
    }
}



@end
