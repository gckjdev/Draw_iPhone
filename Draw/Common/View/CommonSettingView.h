//
//  DiceSettingView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonInfoView.h"

@interface CommonSettingView : CommonInfoView

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *musicImageView;
@property (retain, nonatomic) IBOutlet UIImageView *audioImageView;
@property (retain, nonatomic) IBOutlet UIButton *musicOnButton;
@property (retain, nonatomic) IBOutlet UIButton *musicOffButton;
@property (retain, nonatomic) IBOutlet UIButton *audioOnButton;
@property (retain, nonatomic) IBOutlet UIButton *audioOffButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

+ (id)createSettingView;

@end
