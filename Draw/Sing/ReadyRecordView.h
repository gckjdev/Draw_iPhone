//
//  ReadyRecordView.h
//  Chat
//
//  Created by 王 小涛 on 13-5-17.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordAndPlayProtocol.h"
#import "RecordAndPlayCommonView.h"

@interface ReadyRecordView : RecordAndPlayCommonView <RecordAndPlayProtocol>
@property (retain, nonatomic) IBOutlet UILabel *tipLabel;

+ (id)createView;

@end
