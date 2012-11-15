//
//  BBSManager.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSManager.h"
#import "Bbs.pb.h"
#import "GameMessage.pb.h"

@implementation BBSManager

BBSManager *_staticBBSManager;

enum BBSBoardType {
  BBSBoardTypeParent = 1,
  BBSBoardTypeSub = 2
};

@synthesize boardList = _boardList;

- (id)init
{
    self = [super init];
    if (self) {
        _boardDict = [[NSMutableDictionary alloc] init];
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


+(void)printBBSBoard:(PBBBSBoard *)board
{
    PPDebug(@"Board:[boardId = %@, type = %d, name = %@, icon = %@, parentBoardId = %@, lastPost = %@, topicCount = %d, postCount = %d, desc = %@]",board.boardId, board.type,board.name,board.icon,board.parentBoardId,[board.lastPost description],board.topicCount,board.postCount,board.desc);
}
+(void)printBBSContent:(PBBBSContent *)content
{
    
}
+(void)printBBSUser:(PBBBSUser *)user
{
    
}
+(void)printBBSPost:(PBBBSPost *)post
{
    
}
+(void)printBBSAction:(PBBBSAction *)action
{
    
}

@end
