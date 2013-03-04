//
//  MyPaint.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBDrawBg;
@interface MyPaint : NSManagedObject
{
//    NSData *_drawData;
}

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * drawByMe;
@property (nonatomic, retain) NSNumber * draft;
@property (nonatomic, retain) NSString * drawUserNickName;
@property (nonatomic, retain) NSString * drawUserId;
@property (nonatomic, retain) NSString * drawWord;
@property (nonatomic, retain) NSData * drawThumbnailData;
@property (nonatomic, retain) NSNumber *language;
@property (nonatomic, retain) NSNumber *level;
@property (nonatomic, retain) NSNumber *deleteFlag;
@property (nonatomic, retain) NSString * dataFilePath; //relative
@property (nonatomic, retain) NSString * targetUserId;
@property (nonatomic, retain) NSString * contestId;

@property (nonatomic, retain) UIImage *thumbImage;
@property (nonatomic, retain) NSString *imageFilePath; //full path
@property (nonatomic, retain) NSMutableArray *drawActionList;

@property (nonatomic, retain) NSNumber *isRecovery;
@property (nonatomic, retain) NSData * drawWordData;

@property (nonatomic, assign) NSInteger drawDataVersion;
@property (nonatomic, retain) PBDrawBg *drawBg;

- (void)updateDrawData;

@end
