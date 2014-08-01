//
//  MyPaint.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaint.h"
#import "MyPaintManager.h"
#import "CanvasRect.h"
#import "DrawLayer.h"
#import "DrawConstants.h"

@implementation MyPaint

@dynamic createDate;
@dynamic image;
@dynamic data;
@dynamic drawByMe;
@dynamic drawUserNickName;
@dynamic drawUserId;
@dynamic drawWord;
@dynamic drawThumbnailData;
@dynamic draft;
@dynamic language;
@dynamic level;
@dynamic deleteFlag;
@dynamic dataFilePath;
@dynamic contestId;
@dynamic targetUserId;
@dynamic drawWordData;
@dynamic isRecovery;

@dynamic chapterIndex;
@dynamic chapterOpusId;
@dynamic isForLearn;
@dynamic score;
@dynamic scoreDate;
@dynamic stageId;
@dynamic stageIndex;
@dynamic targetType;
@dynamic tutorialId;
@dynamic stageName;
@dynamic bgImageName;

@synthesize thumbImage = _thumbImage;
@synthesize paintImage = _paintImage;
@synthesize drawActionList = _drawActionList;
@synthesize imageFilePath = _imageFilePath;
@synthesize drawDataVersion = _drawDataVersion;
@synthesize canvasSize = _canvasSize;
@synthesize opusDesc = _opusDesc;
@synthesize bgImage = _bgImage;
@synthesize layers = _layers;
//@synthesize completeDate;
//@synthesize spendTime;
//@synthesize strokes;
@synthesize selectedClassList = _selectedClassList;

@dynamic draftId;
@dynamic opusId;         // opusId returned from Server
@dynamic opusCompleteDate;
@dynamic totalStrokes;
@dynamic opusSpendTime;
@dynamic attributes;

#define IMAGE_SUFFIX @".png"
#define THUMB_IMAGE_SUFFIX @"_m.png"

- (NSString *)thumbImagePath
{
    NSString *path = [self imageFilePath];
    if ([path length] != 0) {
        if ([path hasSuffix:IMAGE_SUFFIX]) {
            path = [path substringToIndex:path.length - IMAGE_SUFFIX.length];
        }
        path = [path stringByAppendingString:THUMB_IMAGE_SUFFIX];
    }
    return path;
}

- (NSString *)imageFilePath
{
    if (_imageFilePath == nil) {
        _imageFilePath = [[MyPaintManager defaultManager] imagePathForPaint:self];
        [_imageFilePath retain];
        PPDebug(@"<MyPaint> imageFilePath = %@",_imageFilePath);
    }
    return _imageFilePath;
}

- (UIImage *)paintImage
{
    if (_paintImage == nil) {
        NSData *data = [NSData dataWithContentsOfFile:self.imageFilePath];
        _paintImage = [UIImage imageWithData:data];
        [_paintImage retain];
        data = nil;
    }
    return _paintImage;
}

- (UIImage *)thumbImage
{
    if (_thumbImage == nil) {
        NSString *thumbImagePath = [self thumbImagePath];

        NSData *data = [NSData dataWithContentsOfFile:thumbImagePath];
        
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:self.imageFilePath];
            _thumbImage = [[MyPaintManager defaultManager] saveImageAsThumb:[UIImage imageWithData:data] path:thumbImagePath];
            [_thumbImage retain];
            
        }else{
            _thumbImage = [[UIImage imageWithData:data] retain];
        }
        data = nil;
    }
    return _thumbImage;
    
}

- (UIImage *)bgImage
{
//    return [[MyPaintManager defaultManager] bgImageForPaint:self];
    if (_bgImage == nil) {
        _bgImage = [[[MyPaintManager defaultManager] bgImageForPaint:self] retain];
    }
    return _bgImage;
}

- (NSMutableArray *)drawActionList
{
    //set draw action list and set the draw data version
    @synchronized(self){
        if (_drawActionList == nil) {
            _drawActionList = [[MyPaintManager defaultManager] drawActionListForPaint:self];
            [_drawActionList retain];
            
            if (_drawActionList == nil){
                self.canvasSize = [CanvasRect defaultRect].size;
                self.layers = [DrawLayer defaultLayersWithFrame:CGRectFromCGSize(self.canvasSize)];
                _drawActionList = [[NSMutableArray alloc] init];
            }
        }
        return _drawActionList;
    }
}
- (void)updateDrawData
{
    [self drawActionList];
}

- (void)dealloc
{
    PPRelease(_selectedClassList);
    PPRelease(_paintImage);
    PPRelease(_thumbImage);
    PPRelease(_drawActionList);
    PPRelease(_imageFilePath);
//    PPRelease(_bgImageName);
    PPRelease(_bgImage);
    PPRelease(_layers);
    [super dealloc];
}

- (int)getTargetType
{
    int type = TypeDraw;
    if (self.targetType){
        type = [self.targetType intValue];
    }
    else{
        if ([self.contestId length] > 0){
            type = TypeContest;
        }
        else{
            type = TypeDraw;
        }
    }
    
    return type;
}

@end
