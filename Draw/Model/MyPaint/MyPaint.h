//
//  MyPaint.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyPaint : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * drawByMe;
@property (nonatomic, retain) NSNumber * isDraft;
@property (nonatomic, retain) NSString * drawUserNickName;
@property (nonatomic, retain) NSString * drawUserId;
@property (nonatomic, retain) NSString * drawWord;
@property (nonatomic, retain) NSData * drawThumbnailData;

@property (nonatomic, retain) UIImage *thumbImage;

@end
