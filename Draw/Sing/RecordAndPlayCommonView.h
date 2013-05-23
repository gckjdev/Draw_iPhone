//
//  RecordAndPlayCommonView.h
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordAndPlayControl;

@interface RecordAndPlayCommonView : UIView

@property (assign, nonatomic) RecordAndPlayControl *control;

- (IBAction)clickControl:(id)sender;

@end
