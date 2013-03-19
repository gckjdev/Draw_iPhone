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
@class PBDrawBg;

//@class pbcom
//@class LanguageType;

@interface Draw : NSObject
{


}
@property (retain, nonatomic) NSString *userId;
@property (retain, nonatomic) NSString *nickName;
@property (retain, nonatomic) NSString *avatar;

@property (retain, nonatomic) NSMutableArray *drawActionList;
@property (retain, nonatomic) Word *word;
@property (assign, nonatomic) LanguageType languageType;

@property (retain, nonatomic) NSDate *date;
@property (assign, nonatomic) NSInteger version;
@property (retain, nonatomic) PBDrawBg *drawBg;
@property (assign, nonatomic) CGSize canvasSize;

- (CGRect)canvasRect;

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName
              avatar:(NSString *)avatar
      drawActionList:(NSMutableArray *)drawActionList 
                word:(Word *)word
              drawBg:(PBDrawBg *)drawBg
          canvasSize:(CGSize)size;

- (id)initWithPBDraw:(PBDraw *)pbDraw;
- (BOOL)isNewVersion;
- (PBDraw *)toPBDraw;
@end
