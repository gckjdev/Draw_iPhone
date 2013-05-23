//
//  SingController.h
//  Chat
//
//  Created by 王 小涛 on 13-5-10.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RecordAndPlayControl.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PPViewController.h"

@interface SingController : PPViewController <AVAudioRecorderDelegate, RecordAndPlayDelegate,
    MPMediaPickerControllerDelegate>
@property (retain, nonatomic) IBOutlet UISlider *progressSlider;

@property (retain, nonatomic) IBOutlet UIView *RecordAndPlayHolderView;

@property (retain, nonatomic) IBOutlet UISlider *durationSlider;
@property (retain, nonatomic) IBOutlet UISlider *pitchSlider;
@property (retain, nonatomic) IBOutlet UILabel *durationLabel;
@property (retain, nonatomic) IBOutlet UILabel *pitchLabel;

@end
