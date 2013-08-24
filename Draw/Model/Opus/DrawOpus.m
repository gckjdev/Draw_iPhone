//
//  DrawOpus.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "DrawOpus.h"
#import "UserManager.h"
#import "ConfigManager.h"

@implementation DrawOpus

+ (NSString*)localDataDir
{
    return @"PaintData";
}

- (NSString *)shareTextWithSNSType:(int)type{
    
    NSString *text = nil;
    if ([[UserManager defaultManager] isMe:self.pbOpus.author.userId]) {
        if (self.pbOpus.desc.length > 0) {
            text = [NSString stringWithFormat:NSLS(@"kShareMyOpusWithDescriptionText"), self.pbOpus.desc, self.pbOpus.author.nickName, self.pbOpus.name, [ConfigManager getSNSShareSubject], [ConfigManager getAppItuneLink]];
        } else {
            text = [NSString stringWithFormat:NSLS(@"kShareMyOpusWithoutDescriptionText"), self.pbOpus.author.nickName, self.pbOpus.name, [ConfigManager getSNSShareSubject], [ConfigManager getAppItuneLink]];
        }
    }else{
        NSString* heStr = [self.pbOpus.author gender] ? NSLS(@"kHim") : NSLS(@"kHer");
        if (self.pbOpus.desc.length > 0) {
            text = [NSString stringWithFormat:NSLS(@"kShareOtherOpusWithDescriptionText"), self.pbOpus.desc, heStr, self.pbOpus.author.nickName, self.pbOpus.name, [ConfigManager getSNSShareSubject], [ConfigManager getAppItuneLink]];
            
        } else {
            text = [NSString stringWithFormat:NSLS(@"kShareOtherOpusWithoutDescriptionText"),  heStr, self.pbOpus.author.nickName, self.pbOpus.name, [ConfigManager getSNSShareSubject], [ConfigManager getAppItuneLink]];
        }
    }
    
    return text;
}

@end
