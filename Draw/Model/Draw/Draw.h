//
//  RemoteDrawData.h
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"

@class PBDrawAction;
@class DrawAction;
@class Word;
@class PBDraw;
//@class pbcom
//@class LanguageType;

@interface Draw : NSObject<NSCoding>
{
    NSString *_userId;
    NSString *_nickName;
    NSMutableArray *_drawActionList;
    Word *_word;
    NSDate *_date;
    NSString *_avatar;
    LanguageType _languageType;

}
@property (retain, nonatomic) NSString *userId;
@property (retain, nonatomic) NSString *nickName;
@property (retain, nonatomic) NSMutableArray *drawActionList;
@property (retain, nonatomic) Word *word;
@property (retain, nonatomic) NSDate *date;
@property (retain, nonatomic) NSString *avatar;
@property (assign, nonatomic) LanguageType languageType;
@property (assign, nonatomic) NSInteger version;

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
      drawActionList:(DrawAction *)drawActionList 
                word:(Word *)word 
                date:(NSDate *)date 
              avatar:(NSString *)avatar;

- (id)initWithPBDraw:(PBDraw *)pbDraw;
- (BOOL)isNewVersion;
//- (id)initWithPBDraw:(PBDraw *)pbDraw;
@end
