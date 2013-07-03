//
//  PBOpusAction+Extend.h
//  Draw
//
//  Created by 王 小涛 on 13-7-1.
//
//

#import "Opus.pb.h"

@interface PBOpusAction (Extend)

- (NSAttributedString *)actionAttributedStringWithFont:(UIFont *)font;
- (NSString *)actionString;

- (NSString *)createTimeString;

@end
