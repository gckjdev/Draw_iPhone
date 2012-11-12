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

@synthesize thumbImage = _thumbImage;
@synthesize drawActionList = _drawActionList;
@synthesize imageFilePath = _imageFilePath;


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

- (NSMutableArray *)drawActionList
{
    if (_drawActionList == nil) {
        _drawActionList = [[MyPaintManager defaultManager] drawActionListForPaint:self];
        [_drawActionList retain];
    }
    return _drawActionList;
}

- (void)dealloc
{
    PPRelease(_thumbImage);
    PPRelease(_drawActionList);
    PPRelease(_imageFilePath);
    [super dealloc];
}

@end
