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

@interface SingController : PPViewController <InputDialogDelegate, ChangeAvatarDelegate, OpusServiceDelegate, VoiceRecorderDelegate, VoiceChangerDelegate, VoiceProcessorDelegate>

@property (retain, nonatomic) IBOutlet UIButton *originButton;
@property (retain, nonatomic) IBOutlet UIButton *tomCatButton;
@property (retain, nonatomic) IBOutlet UIButton *duckButton;
@property (retain, nonatomic) IBOutlet UIButton *maleButton;
@property (retain, nonatomic) IBOutlet UIButton *childButton;
@property (retain, nonatomic) IBOutlet UIButton *femaleButton;
@property (retain, nonatomic) IBOutlet UIImageView *tagButton;
@property (retain, nonatomic) IBOutlet UILabel *songNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *songNameLabel1;
@property (retain, nonatomic) IBOutlet UILabel *songAuthorLabel;
@property (retain, nonatomic) IBOutlet UILabel *songAuthorLabel1;
@property (retain, nonatomic) IBOutlet UITextView *lyricTextView;
@property (retain, nonatomic) IBOutlet UIImageView *micImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *playImageView;
@property (retain, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (retain, nonatomic) IBOutlet UIButton *rerecordButton;
@property (retain, nonatomic) IBOutlet UIButton *addTimeButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *opusImageButton;
@property (retain, nonatomic) IBOutlet UIView *opusMainView;
@property (retain, nonatomic) IBOutlet UIView *opusReview;

// if select a song, load with this.
- (id)initWithSong:(PBSong *)song;

// if self define, load with this.
- (id)initWithName:(NSString *)name;

// if load form draft, use this method.
- (id)initWithOpus:(SingOpus *)opus;

@end
