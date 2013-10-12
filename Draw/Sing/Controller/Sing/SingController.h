//
//  SingController.h
//  Chat
//
//  Created by 王 小涛 on 13-5-10.
//  Copyright (c) 2013年 王 小涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PPViewController.h"
#import "ChangeAvatar.h"
#import "Sing.pb.h"
#import "OpusService.h"
#import "SingOpus.h"
#import "VoiceRecorder.h"
#import "VoiceChanger.h"
#import "VoiceProcessor.h"

@interface SingController : PPViewController <ChangeAvatarDelegate, OpusServiceDelegate, VoiceRecorderDelegate, VoiceChangerDelegate, VoiceProcessorDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *micImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *playImageView;
@property (retain, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (retain, nonatomic) IBOutlet UIButton *rerecordButton;
@property (retain, nonatomic) IBOutlet UIButton *addTimeButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIView *opusMainView;

@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;
@property (retain, nonatomic) IBOutlet UILabel *opusDescLabel;

//// if select a song, load with this.
//- (id)initWithSong:(PBSong *)song;
//
//// if self define, load with this.
//- (id)initWithName:(NSString *)name;

// if direct in, call this method.
- (id)init;

// if load form draft, use this method.
- (id)initWithOpus:(SingOpus *)opus;

@end
