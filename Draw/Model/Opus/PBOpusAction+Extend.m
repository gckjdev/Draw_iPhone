//
//  PBOpusAction+Extend.m
//  Draw
//
//  Created by 王 小涛 on 13-7-1.
//
//

#import "PBOpusAction+Extend.h"
#import "StringUtil.h"
#import "NSArray+Extend.h"
#import "TimeUtils.h"

@implementation PBOpusAction (Extend)

- (NSAttributedString *)actionAttributedStringWithFont:(UIFont *)font{
    
    NSString *str = [self actionString];
    NSMutableAttributedString *attr = [[[NSMutableAttributedString alloc] initWithString:str] autorelease];
    
    [attr addAttribute:NSFontAttributeName
                 value:font
                 range:NSMakeRange(0, str.length)];
    
    if (self.actionType == PBOpusActionTypeOpusActionTypeComment) {
        
        [attr addAttribute:NSForegroundColorAttributeName
                     value:[UIColor lightGrayColor]
                     range:NSMakeRange(0, str.length - self.commentAction.content.length)];
    }
    
    return attr;
}

- (NSString *)actionString{
    
    switch (self.actionType) {
        case PBOpusActionTypeOpusActionTypeFlower:
            return [self flowerActionString];
            break;
            
        case PBOpusActionTypeOpusActionTypeGuess:
            return [self guessActionString];
            break;
            
        case PBOpusActionTypeOpusActionTypeComment:
            return [self commentActionString];
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (NSString *)createTimeString{

    NSString *timeString = nil;
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(self.createDate);
    } else {
        timeString = englishBeforeTime(self.createDate);
    }
    
    return timeString;
}

- (NSString *)guessActionString{
    
    NSArray *guessWords = self.guessAction.wordsList;
    
    NSString *comment = nil;
    NSInteger wordCount = [guessWords count];
    if (wordCount != 0) {
        
        NSArray *wordList = [guessWords subarrayWithRangeSafe:NSMakeRange(0, 3)];
        
        if ([LocaleUtils isChinese]) {
            comment = [wordList componentsJoinedByString:@"、"];
        }else{
            comment = [wordList componentsJoinedByString:@", "];
        }
        
        if ([LocaleUtils isTraditionalChinese]) {
            comment = [comment toTraditionalChinese];
        }
        if (wordCount > 3) {
            comment = [NSString stringWithFormat:@"%@%@",guessWords,@"..."];
        }
        comment = [NSString stringWithFormat:NSLS(@"kGuessWords"),comment];
    }
    
    if (comment == nil) {
        comment = NSLS(@"kGuessWrong");
    }
    
    return comment;
}

- (NSString *)flowerActionString{
    
    return NSLS(@"kSendAFlower");
}

- (NSString *)commentActionString{
    
    NSString *comment = nil;
    
    if ([self hasSourceAction]) {
        
        comment = [NSString stringWithFormat:NSLS(@"kReplyCommentDesc"), self.sourceAction.userInfo.nickName, self.commentAction.content];
        
    }else{
        comment = self.commentAction.content;
    }
    
    return comment;
}




@end
