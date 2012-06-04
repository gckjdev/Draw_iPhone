//
//  CustomWord.h
//  Draw
//
//  Created by haodong qiu on 12年6月4日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomWord : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSNumber * language;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * lastUseDate;
@property (nonatomic, retain) NSNumber * level;

@end
