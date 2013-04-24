//
//  MyPaint.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaint.h"
#import "MyPaintManager.h"

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

@synthesize thumbImage = _thumbImage;
@synthesize drawActionList = _drawActionList;
@synthesize imageFilePath = _imageFilePath;
@synthesize drawDataVersion = _drawDataVersion;
@synthesize canvasSize = _canvasSize;
@synthesize opusDesc = _opusDesc;
@synthesize bgImageName = _bgImageName;
@synthesize bgImage = _bgImage;

- (NSString *)imageFilePath
{
    if (_imageFilePath == nil) {
        _imageFilePath = [[MyPaintManager defaultManager] imagePathForPaint:self];
        [_imageFilePath retain];
        PPDebug(@"<MyPaint> imageFilePath = %@",_imageFilePath);
    }
    return _imageFilePath;
}

- (UIImage *)thumbImage
{
    if (_thumbImage == nil) {
        NSData *data = [NSData dataWithContentsOfFile:self.imageFilePath];
        _thumbImage = [UIImage imageWithData:data];
        [_thumbImage retain];
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
    if (_drawActionList == nil) {
        _drawActionList = [[MyPaintManager defaultManager] drawActionListForPaint:self];
        [_drawActionList retain];
    }
    return _drawActionList;
}
- (void)updateDrawData
{
    [self drawActionList];
}

- (void)dealloc
{
    PPRelease(_thumbImage);
    PPRelease(_drawActionList);
    PPRelease(_imageFilePath);
    PPRelease(_bgImageName);
    PPRelease(_bgImage);
    [super dealloc];
}

@end
