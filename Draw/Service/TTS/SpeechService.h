//
//  SpeechService.h
//  Draw
//
//  Created by haodong qiu on 12年5月31日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iFlyTTS/IFlySynthesizerControl.h"

@interface SpeechService : NSObject<IFlySynthesizerControlDelegate>

+ (SpeechService *)defaultService;

- (void)play:(NSString *)text gender:(BOOL)isMale;

- (void)play:(NSString *)text gender:(BOOL)isMale speed:(unsigned int)speed

- (void)cancel;

@end
