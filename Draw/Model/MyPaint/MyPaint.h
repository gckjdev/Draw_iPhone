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

@property (nonatomic, retain) UIImage *paintImage;
@property (nonatomic, retain) NSString *imageFilePath; //full path
@property (nonatomic, retain) NSMutableArray *drawActionList;

@property(nonatomic, retain) UIImage *thumbImage;

// add for tutorial
@property (nonatomic, retain) NSNumber *chapterIndex;
@property (nonatomic, retain) NSString *chapterOpusId;
@property (nonatomic, retain) NSNumber *isForLearn;
@property (nonatomic, retain) NSNumber *score;
@property (nonatomic, retain) NSDate *scoreDate;
@property (nonatomic, retain) NSString *stageId;
@property (nonatomic, retain) NSNumber *stageIndex;
@property (nonatomic, retain) NSNumber *targetType;
@property (nonatomic, retain) NSString *tutorialId;



@property (nonatomic, retain) NSNumber *isRecovery;
@property (nonatomic, retain) NSData * drawWordData;

@property (nonatomic, assign) NSInteger drawDataVersion;
@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, retain) NSString *opusDesc;
@property (nonatomic, retain) NSArray *layers;

@property (nonatomic, retain) NSString *bgImageName;
@property (nonatomic, retain) UIImage *bgImage;

//@property (nonatomic, assign) int spendTime;
//@property (nonatomic, assign) int64_t strokes;
//@property (nonatomic, assign) int completeDate;
@property (nonatomic, retain) NSArray *selectedClassList;

@property (nonatomic, retain) NSString *draftId;
@property (nonatomic, retain) NSString *opusId;         // opusId returned from Server
@property (nonatomic, retain) NSDate *opusCompleteDate;
@property (nonatomic, retain) NSNumber *totalStrokes;
@property (nonatomic, retain) NSNumber *opusSpendTime;
@property (nonatomic, retain) NSData *attributes;


- (int)getTargetType;
- (void)updateDrawData;

@end
