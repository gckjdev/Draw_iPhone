//
//  RouterTrafficServer.h
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RouterTrafficServer : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * capacity;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * language;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSString * serverKey;
@property (nonatomic, retain) NSNumber * usage;

+ (NSString*)keyWithServerAddress:(NSString*)address port:(int)port;
- (NSString*)key;

@end
