//
//  BBSManager.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import <Foundation/Foundation.h>
#import "BBSModelExt.h"
#import "StorageManager.h"


@interface BBSManager : NSObject
{
    NSArray *_boardList;
    NSMutableDictionary *_boardDict;
    StorageManager *_storageManager;
}
@property(nonatomic, retain)NSArray *boardList;

+(BBSManager *)defaultManager;
-(NSArray *)parentBoardList;
-(NSArray *)sbuBoardListForBoardId:(NSString *)boardId;

//create limit
- (void)updateLastCreationDate;
- (NSTimeInterval)creationFrequency;
- (BOOL)isCreationFrequent;

- (NSUInteger)textMaxLength;
- (NSUInteger)textMinLength;


//Cache
- (void)cacheBBSDrawData:(PBBBSDraw *)draw forKey:(NSString *)key;
- (PBBBSDraw *)loadBBSDrawDataFromCacheWithKey:(NSString *)key;
- (void)deleteAllBBSDrawDataCache;
- (void)deleteOldBBSDrawDataCache;

+(void)printBBSBoard:(PBBBSBoard *)board;
+(void)printBBSContent:(PBBBSContent *)content;
+(void)printBBSUser:(PBBBSUser *)user;
+(void)printBBSPost:(PBBBSPost *)post;
+(void)printBBSAction:(PBBBSAction *)action;


@end
