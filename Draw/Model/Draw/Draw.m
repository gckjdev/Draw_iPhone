//
//  RemoteDrawData.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "Draw.h"
#import "DrawAction.h"
#import "GameBasic.pb.h"
#import "Draw.pb.h"
#import "Word.h"
#import "TimeUtils.h"
#import "ConfigManager.h"
#import "CanvasRect.h"

@implementation Draw

- (void)dealloc{
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_drawActionList);
    PPRelease(_word);
    PPRelease(_date);
    PPRelease(_avatar);
    PPRelease(_drawBg);
    [super dealloc];
}


- (NSArray *)drawActionListFromPBActions:(NSArray *)array
{
    if (array) {
        NSMutableArray *list = [NSMutableArray array];
        for (PBDrawAction *action in array) {
            DrawAction *drawAction = [DrawAction drawActionWithPBDrawAction:action];
            [list addObject:drawAction];
        }
        return list;
    }
    return nil;
}

- (id)initWithPBDraw:(PBDraw *)pbDraw
{
    self = [super init];
    if (self && pbDraw) {
        self.userId = pbDraw.userId;
        self.nickName = pbDraw.nickName;
        self.word = [Word wordWithText:pbDraw.word level:pbDraw.level score:pbDraw.score];
        self.avatar = pbDraw.avatar;
        self.languageType = pbDraw.language;
        self.date = [NSDate dateWithTimeIntervalSince1970: pbDraw.createDate];
        self.drawActionList = [NSMutableArray arrayWithArray:[self drawActionListFromPBActions:pbDraw.drawDataList]];
        self.version = pbDraw.version;
        self.drawBg = pbDraw.drawBg;
        if ([pbDraw hasCanvasSize]) {
            self.canvasSize = CGSizeFromPBSize(pbDraw.canvasSize);
        }else{
            self.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
        }
    }
    return self;
}

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName
              avatar:(NSString *)avatar
      drawActionList:(NSMutableArray *)drawActionList
                word:(Word *)word
              drawBg:(PBDrawBg *)drawBg
          canvasSize:(CGSize)size;
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
        self.avatar = avatar;
        self.drawActionList = drawActionList;
        self.word = word;
        self.drawBg = drawBg;
        self.date = [NSDate date];
        self.languageType = [[UserManager defaultManager] getLanguageType];
        self.version = [ConfigManager currentDrawDataVersion];
        self.canvasSize = size;
    }
    return self;
}


- (CGRect)canvasRect
{
    CGRect rect = CGRectZero;
    rect.size = self.canvasSize;
    return rect;
}

- (BOOL)isNewVersion
{
    return [ConfigManager currentDrawDataVersion] < self.version;
}

- (PBDraw *)toPBDraw
{
    PBDraw_Builder* builder = [[PBDraw_Builder alloc] init];
    [builder setUserId:self.userId];
    [builder setNickName:self.nickName];
    [builder setAvatar:self.avatar];
    [builder setWord:[self.word text]];
    
    [builder setLevel:[self.word level]];
    [builder setLanguage:self.languageType];
    [builder setScore:[self.word score]];
    
    if (self.drawBg != nil){
        [builder setDrawBg:self.drawBg];
    }
    
    [builder setCanvasSize:CGSizeToPBSize(self.canvasSize)];
    
    for (DrawAction* drawAction in self.drawActionList){
        PBDrawAction *action = [drawAction toPBDrawAction];
        if (action) {
            [builder addDrawData:action];
        }

    }
    [builder setVersion:[ConfigManager currentDrawDataVersion]];
    [builder setIsCompressed:YES];
    
    PBDraw* draw = [builder build];
    [builder release];
    
    return draw;

}

@end
