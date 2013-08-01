//
//  RemoteDrawData.h
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"
#import "DrawLayer.h"

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
@property (retain, nonatomic) NSArray *layers;
@property (assign, nonatomic) NSInteger version;
@property (assign, nonatomic) CGSize canvasSize;

- (CGRect)canvasRect;



+ (NSArray *)drawActionListFromPBActions:(Game__PBDrawAction **)array
                             actionCount:(int)actionCount
                              canvasSize:(CGSize)canvasSize;


- (id)initWithPBDrawC:(Game__PBDraw*)pbDrawC;

- (BOOL)isNewVersion;

@end
