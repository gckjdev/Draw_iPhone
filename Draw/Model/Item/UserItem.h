//
//  UserItem.h
//  Draw
//
//  Created by  on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserItem : NSManagedObject

@property (nonatomic, retain) NSNumber * itemType;
@property (nonatomic, retain) NSNumber * amount;

@end
