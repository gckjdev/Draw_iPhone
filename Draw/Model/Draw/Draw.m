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
#import "GameBasic.pb-c.h"
#import "Draw.pb-c.h"
#import "ClipAction.h"

@implementation Draw

- (void)dealloc{
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_drawActionList);
    PPRelease(_word);
    PPRelease(_date);
    PPRelease(_avatar);
    PPRelease(_layers);
    [super dealloc];
}

+ (NSArray *)drawActionListFromPBActions:(Game__PBDrawAction **)array
                             actionCount:(int)actionCount
                              canvasSize:(CGSize)canvasSize
{
    if (array != NULL) {
        
        NSMutableArray *list = [NSMutableArray array];
        ClipAction *clipAction = nil;        
        for (int i=0; i<actionCount; i++){
            
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

            Game__PBDrawAction* pbDrawActionC = array[i];
            if (pbDrawActionC != NULL){
                DrawAction* drawAction = [DrawAction drawActionWithPBDrawActionC:pbDrawActionC];
                if ([drawAction isClipAction]) {
                    clipAction = (ClipAction *) drawAction;
                }
                if (drawAction.clipTag == clipAction.clipTag) {
                    drawAction.clipAction = clipAction;
                }

                [drawAction setCanvasSize:canvasSize];
                if (drawAction) {
                    [list addObject:drawAction];
                }
            }
            
            [pool drain];
        }
        
        return list;
        
        //        NSMutableArray *list = [NSMutableArray array];
        //        for (PBDrawAction *action in array) {
        //            DrawAction *drawAction = [DrawAction drawActionWithPBDrawAction:action];
        //            [drawAction setCanvasSize:canvasSize];
        //            [list addObject:drawAction];
        //        }
        //        return list;
    }
    return nil;
}

/*
- (NSArray *)drawActionListFromPBActions:(Game__PBDrawAction **)array
                             actionCount:(int)actionCount
                              canvasSize:(CGSize)canvasSize
{
    if (array != NULL) {
        
        NSMutableArray *list = [NSMutableArray array];
        for (int i=0; i<actionCount; i++){
            
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            
            Game__PBDrawAction* pbDrawActionC = array[i];
            if (pbDrawActionC != NULL){
                DrawAction* drawAction = [DrawAction drawActionWithPBDrawActionC:pbDrawActionC];
                [drawAction setCanvasSize:canvasSize];
                [list addObject:drawAction];
            }
            
            [pool drain];
        }
        
        return list;
        
//        NSMutableArray *list = [NSMutableArray array];
//        for (PBDrawAction *action in array) {
//            DrawAction *drawAction = [DrawAction drawActionWithPBDrawAction:action];
//            [drawAction setCanvasSize:canvasSize];
//            [list addObject:drawAction];
//        }
//        return list;
    }
    return nil;
}
*/

- (NSArray *)drawActionListFromPBActions:(NSArray *)array canvasSize:(CGSize)canvasSize
{
    if (array) {
        NSMutableArray *list = [NSMutableArray array];
        for (PBDrawAction *action in array) {
            
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            
            DrawAction *drawAction = [DrawAction drawActionWithPBDrawAction:action];
            [drawAction setCanvasSize:canvasSize];
            [list addObject:drawAction];
            
            [pool drain];
        }
        return list;
    }
    return nil;
}

- (id)initWithPBDrawC:(Game__PBDraw*)pbDrawC
{
    self = [super init];
    if (self && pbDrawC != NULL) {
        self.userId = [NSString stringWithUTF8String:pbDrawC->userid];
        self.nickName = [NSString stringWithUTF8String:pbDrawC->nickname];
        
        NSString* word = [NSString stringWithUTF8String:pbDrawC->word];
        int level = pbDrawC->level;
        int score = pbDrawC->score;
        
        self.word = [Word wordWithText:word level:level score:score];
        
        NSString* avatar = [NSString stringWithUTF8String:pbDrawC->avatar];
        self.avatar = avatar;
        
        self.languageType = pbDrawC->language;
        self.date = [NSDate dateWithTimeIntervalSince1970:pbDrawC->createdate];
        
        self.version = pbDrawC->version;
        if (pbDrawC->canvassize != NULL) {
//            self.canvasSize = CGSizeFromPBSize(pbDraw.canvasSize);
            self.canvasSize = CGSizeFromPBSizeC(pbDrawC->canvassize);
        }else{
            self.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
        }
        
        self.drawActionList = [NSMutableArray arrayWithArray:[Draw drawActionListFromPBActions:pbDrawC->drawdata
                                                                                   actionCount:pbDrawC->n_drawdata
                                                                                    canvasSize:self.canvasSize]];
        
        //TODO update layers
    }
    return self;
    
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

        self.version = pbDraw.version;
        if ([pbDraw hasCanvasSize]) {
            self.canvasSize = CGSizeFromPBSize(pbDraw.canvasSize);
        }else{
            self.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
        }
        self.drawActionList = [NSMutableArray arrayWithArray:[self drawActionListFromPBActions:pbDraw.drawDataList canvasSize:self.canvasSize]];
    }
    return self;
}

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName
              avatar:(NSString *)avatar
      drawActionList:(NSMutableArray *)drawActionList
                word:(Word *)word
          canvasSize:(CGSize)size;
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
        self.avatar = avatar;
        self.drawActionList = drawActionList;
        self.word = word;
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
