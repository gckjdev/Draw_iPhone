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
#import "BBSImageManager.h"
#import "BBSFontManager.h"
#import "BBSColorManager.h"
#import "BBSViewManager.h"

@interface BBSManager : NSObject
{
    NSArray *_boardList;
    NSMutableDictionary *_boardDict;
    StorageManager *_storageManager;
    NSMutableArray *_tempPostList;
}
@property(nonatomic, retain)NSArray *boardList;
@property(nonatomic, retain)NSMutableArray *tempPostList;

+(BBSManager *)defaultManager;
-(NSArray *)parentBoardList;
-(NSArray *)sbuBoardListForBoardId:(NSString *)boardId;

- (PBBBSBoard *)boardForBoardId:(NSString *)boardId;
- (PBBBSBoard *)parentBoardOfsubBoard:(PBBBSBoard *)subBoard;

//create limit
- (void)updateLastCreationDate;
- (NSTimeInterval)creationFrequency;
- (BOOL)isCreationFrequent;

//support limit
- (NSUInteger)supportMaxTimes;
- (void)increasePostSupportTimes:(NSString *)postId;
- (BOOL)canSupportPost:(NSString *)postId;

//content
- (NSUInteger)textMaxLength;
- (NSUInteger)textMinLength;

//temp post list methods

- (PBBBSPost *)inceasePost:(PBBBSPost *)post
              commentCount:(NSInteger)inc;
- (PBBBSPost *)inceasePost:(PBBBSPost *)post
              supportCount:(NSInteger)inc;
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
