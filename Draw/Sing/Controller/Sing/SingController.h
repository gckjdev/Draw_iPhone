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
#import "StrokeLabel.h"
#import "UIPlaceholderTextView.h"
#import "Contest.h"

@interface SingController : PPViewController <ChangeAvatarDelegate, OpusServiceDelegate, VoiceRecorderDelegate, VoiceChangerDelegate, VoiceProcessorDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *micImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *playImageView;
@property (retain, nonatomic) IBOutlet UIImageView *pauseImageView;

@property (retain, nonatomic) IBOutlet UITextView *lyricTextView;
@property (retain, nonatomic) IBOutlet UIImageView *lyricBgImageView;

@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;
@property (retain, nonatomic) IBOutlet StrokeLabel *opusDescLabel;
@property (retain, nonatomic) IBOutlet UIButton *imageButton;

@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;

@property (retain, nonatomic) IBOutlet UIButton *voiceButton;
@property (retain, nonatomic) IBOutlet UIButton *rerecordButton;
@property (retain, nonatomic) IBOutlet UIButton *searchSongButton;
@property (retain, nonatomic) IBOutlet UIButton *descButton;
@property (retain, nonatomic) IBOutlet UIButton *reviewButton;
@property (retain, nonatomic) IBOutlet UIPlaceholderTextView *descTextView;

//// if select a song, load with this.
//- (id)initWithSong:(PBSong *)song;
//
//// if self define, load with this.
//- (id)initWithName:(NSString *)name;

// if direct in, call this method.
- (id)init;

// if you want to create opus for some one. call this method.
- (id)initWithTargetUser:(PBGameUser *)targetUser;

// if load form draft, use this method.
- (id)initWithOpus:(SingOpus *)opus;

// if load from contest, use this method.
- (id)initWithContest:(Contest *)contest;

@end
