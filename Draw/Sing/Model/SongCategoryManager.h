//
//  SongCategoryManager.h
//  Draw
//
//  Created by 王 小涛 on 13-6-13.
//
//

#import <Foundation/Foundation.h>

@interface SongCategoryManager : NSObject
@property (readonly, retain, nonatomic) NSMutableArray *categorys;


+ (id)defaultManager;
- (void)syncData;

//+ (NSArray *)createTestData;

@end
