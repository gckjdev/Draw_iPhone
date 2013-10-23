//
//  VoiceTypeSelectView.h
//  Draw
//
//  Created by 王 小涛 on 13-10-15.
//
//

#import <UIKit/UIKit.h>
#import "SingOpus.h"

@protocol VoiceTypeSelectViewDelegate <NSObject>

- (void)didSelectVoiceType:(PBVoiceType)voiceType;

@end

@interface VoiceTypeSelectView : UIView

@property (assign, nonatomic) id delegate;

+ (id)createWithVoiceType:(PBVoiceType)voiceType;

@end
