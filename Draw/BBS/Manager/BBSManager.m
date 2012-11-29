//
//  BBSManager.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSManager.h"
#import "GameMessage.pb.h"

@implementation BBSManager

BBSManager *_staticBBSManager;

#define DRAW_DATA_CACHE_DIR @"bbs/drawData"
#define CACHE_LIFE_TIME 3600 * 24 * 5
@synthesize boardList = _boardList;

- (id)init
{
    self = [super init];
    if (self) {
        _boardDict = [[NSMutableDictionary alloc] init];
        _storageManager = [[StorageManager alloc] initWithStoreType:StorageTypeCache
                                                      directoryName:DRAW_DATA_CACHE_DIR];
    }
    return self;
}

+ (BBSManager *)defaultManager
{
    if (_staticBBSManager == nil) {
        _staticBBSManager = [[BBSManager alloc] init];
    }
    return _staticBBSManager;
}

- (void)dealloc
{
    PPRelease(_boardList);
    PPRelease(_boardDict);
    PPRelease(_storageManager);
    [super dealloc];
}

- (void)resetBoardDict
{
    [_boardDict removeAllObjects];
    NSArray *list = [self parentBoardList];
    for (PBBBSBoard *pBoard in list) {
        NSString *key = pBoard.boardId;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.parentBoardId==%@",key];
        NSArray* subList = [_boardList filteredArrayUsingPredicate:predicate];
        [_boardDict setObject:subList forKey:key];
    }
}

- (void)setBoardList:(NSArray *)boardList
{
    if (_boardList != boardList) {
        [_boardList release];
        _boardList = [boardList retain];
        [self resetBoardDict];
    }
}

- (NSArray *)parentBoardList
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type==%d",BBSBoardTypeParent];
    return [_boardList filteredArrayUsingPredicate:predicate];
}

- (NSArray *)sbuBoardListForBoardId:(NSString *)boardId
{
    return [_boardDict objectForKey:boardId];
}

- (PBBBSBoard *)boardForBoardId:(NSString *)boardId
{
    for (PBBBSBoard *board in self.boardList) {
        if ([board.boardId isEqualToString:boardId]) {
            return board;
        }
    }
    return nil;
}
- (PBBBSBoard *)parentBoardOfsubBoard:(PBBBSBoard *)subBoard
{
    if (subBoard) {
        return [self boardForBoardId:subBoard.parentBoardId];
    }
    return nil;
}


#pragma mark - create post&&action limit

#define FREQUENCY_KEY @"FREQUENCY_KEY"
- (void)updateLastCreationDate
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setDouble:interval forKey:FREQUENCY_KEY];
    [ud synchronize];
}

- (NSTimeInterval)lastCreationDateInterval
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud doubleForKey:FREQUENCY_KEY];
}

- (NSTimeInterval)creationFrequency
{
    return 15; //10 seconds
}
- (BOOL)isCreationFrequent
{
    NSTimeInterval it =[[NSDate date] timeIntervalSince1970] - [self lastCreationDateInterval];
    return (it < [self creationFrequency]);
}

- (NSUInteger)textMaxLength
{
    return 3000;
}

- (NSUInteger)textMinLength
{
    return 5;
}

#pragma draw data Cache
- (void)cacheBBSDrawData:(PBBBSDraw *)draw forKey:(NSString *)key
{
    [_storageManager saveData:[draw data] forKey:key];
}
- (PBBBSDraw *)loadBBSDrawDataFromCacheWithKey:(NSString *)key
{
    NSData *data = [_storageManager dataForKey:key];
    if (data) {
        return [PBBBSDraw parseFromData:data];
    }
    return nil;
}
- (void)deleteAllBBSDrawDataCache
{
    [_storageManager removeAllData];
}
- (void)deleteOldBBSDrawDataCache
{
    [_storageManager removeOldFilestimeIntervalSinceNow:CACHE_LIFE_TIME];
}


+(void)printBBSBoard:(PBBBSBoard *)board
{
    PPDebug(@"Board:[boardId = %@,\n type = %d,\n name = %@,\n icon = %@,\n parentBoardId = %@,\n lastPost = %@,\n actionCount = %d,\n postCount = %d,\n desc = %@]",board.boardId, board.type,board.name,board.icon,board.parentBoardId,[board.lastPost description],board.actionCount,board.postCount,board.desc);
}
+(void)printBBSContent:(PBBBSContent *)content
{
    PPDebug(@"Content:[text = %@,type = %d, image = %@, thumb = %@, drawImage = %@, drawThumb = %@]",content.text,content.type,content.imageUrl,content.thumbImageUrl,content.drawImageUrl,content.drawThumbUrl);
}
+(void)printBBSUser:(PBBBSUser *)user
{
    PPDebug(@"User:[userId = %@,\n nickName = %@,\n gender = %d,\n avatar = %@]",user.userId, user.nickName,user.gender,user.avatar);
}
+(void)printBBSPost:(PBBBSPost *)post
{
    PPDebug(@"Post:[postId = %@,\n replyCount = %d,\n supportCount = %d]",post.postId,post.replyCount,post.supportCount);
    [BBSManager printBBSUser:post.createUser];
    [BBSManager printBBSContent:post.content];

}
+(void)printBBSAction:(PBBBSAction *)action
{
    
}

@end
