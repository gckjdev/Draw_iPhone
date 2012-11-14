//
//  BBSManager.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSManager.h"

@implementation BBSManager
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
