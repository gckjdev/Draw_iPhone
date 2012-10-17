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


- (NSData *)drawData
{
    if ([self.dataFilePath length] != 0) {
        _drawData = [MyPaintManager drawDataFromDataPath:self.dataFilePath];
        [_drawData retain];
        return _drawData;
    }else{
        return self.data;
    }
}

- (void)dealloc
{
    PPRelease(_thumbImage);
    PPRelease(_drawData);
    [super dealloc];
}

@end
