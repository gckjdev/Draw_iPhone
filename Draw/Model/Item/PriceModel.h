//
//  PriceModel.h
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PriceModel : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSNumber * savePercent;
@property (nonatomic, retain) NSNumber * type;

@end
