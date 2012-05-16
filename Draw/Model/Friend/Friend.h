//
//  Friend.h
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * friendUserId;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * sinaId;
@property (nonatomic, retain) NSString * qqId;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * sinaNick;
@property (nonatomic, retain) NSString * qqNick;
@property (nonatomic, retain) NSString * facebookNick;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * onlineStatus;
@property (nonatomic, retain) NSDate   * createDate;
@property (nonatomic, retain) NSDate   * lastModifiedDate;
@property (nonatomic, retain) NSNumber * deleteFlag;
@property (nonatomic, retain) NSString * location;

@end
