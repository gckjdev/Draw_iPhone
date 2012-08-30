//
//  DiceSettingView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonInfoView.h"
#import "FontButton.h"

@interface DiceSettingView : CommonInfoView

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *musicImageView;
@property (retain, nonatomic) IBOutlet UIImageView *audioImageView;
@property (retain, nonatomic) IBOutlet FontButton *musicOnButton;
@property (retain, nonatomic) IBOutlet FontButton *musicOffButton;
@property (retain, nonatomic) IBOutlet FontButton *audioOnButton;
@property (retain, nonatomic) IBOutlet FontButton *audioOffButton;
@property (retain, nonatomic) IBOutlet FontButton *closeButton;

+ (id)createDiceSettingView;

@end
