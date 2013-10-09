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
#import "DrawUtils.h"

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

//        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        ClipAction *clipAction = nil;
            NSMutableDictionary *clipDict = [NSMutableDictionary dictionary];
//            int progress = 0;
//            NSMutableDictionary* progressUserInfo = [NSMutableDictionary dictionary];
            for (int i=0; i<actionCount; i++){
                
                NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

                Game__PBDrawAction* pbDrawActionC = array[i];
                if (pbDrawActionC != NULL){
                    DrawAction* at = [DrawAction drawActionWithPBDrawActionC:pbDrawActionC];
                    if (at) {
                        if ([at isKindOfClass:[ClipAction class]]) {
                            [clipDict setObject:at forKey:@(at.layerTag)];
                            [at finishAddPoint];
                        }else{
                            ClipAction *clipAction = [clipDict objectForKey:@(at.layerTag)];
                            if (at.clipTag == clipAction.clipTag) {
                                at.clipAction = clipAction;
                            }
                        }
                        [at setCanvasSize:canvasSize];
                        [list addObject:at];
                        at = nil;
                    }
                }
                
//                progress = i*1000 / actionCount;
//                if (progress % 50 == 0){
//                    [progressUserInfo setObject:@((CGFloat)progress/1000.f) forKey:KEY_DATA_PARSING_PROGRESS];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DATA_PARSING object:nil userInfo:progressUserInfo];
//                }
                
                [pool drain];
            }
//        });
        
        
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
            self.canvasSize = CGSizeFromPBSizeC(pbDrawC->canvassize);
        }else{
            self.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
        }
        
        
        NSArray *list = [Draw drawActionListFromPBActions:pbDrawC->drawdata
                                              actionCount:pbDrawC->n_drawdata
                                               canvasSize:self.canvasSize];

        self.layers = [DrawLayer layersFromPBLayers:pbDrawC->layer number:pbDrawC->n_layer];

        if (self.layers == nil) {
            self.layers = [DrawLayer defaultOldLayersWithFrame:CGRectFromCGSize(self.canvasSize)];
        }

        
        self.drawActionList = (id)(([list isKindOfClass:[NSMutableArray class]] || list == nil) ?  list : [NSMutableArray arrayWithArray:list]);
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
@end
