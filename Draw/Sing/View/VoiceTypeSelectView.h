//
//  VoiceTypeSelectView.h
//  Draw
//
//  Created by 王 小涛 on 13-10-15.
//
//

#import <UIKit/UIKit.h>
#import "SingOpus.h"

@interface VoiceTypeSelectView : UIView

+ (id)createWithVoiceType:(PBVoiceType)voiceType;
- (PBVoiceType)getVoiceType;

@end
