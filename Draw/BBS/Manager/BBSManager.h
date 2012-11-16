//
//  BBSManager.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import <Foundation/Foundation.h>
#import "Bbs.pb.h"

enum BBSBoardType {
    BBSBoardTypeParent = 1,
    BBSBoardTypeSub = 2
};

typedef enum {
    ContentTypeNo = 0,
    ContentTypeText = 1,
    ContentTypeImage = 2,
    ContentTypeDraw = 4
}BBSPostContentType;


@interface BBSManager : NSObject
{
    NSArray *_boardList;
    NSMutableDictionary *_boardDict;
}
@property(nonatomic, retain)NSArray *boardList;

+(BBSManager *)defaultManager;
-(NSArray *)parentBoardList;
-(NSArray *)sbuBoardListForBoardId:(NSString *)boardId;

+(void)printBBSBoard:(PBBBSBoard *)board;
+(void)printBBSContent:(PBBBSContent *)content;
+(void)printBBSUser:(PBBBSUser *)user;
+(void)printBBSPost:(PBBBSPost *)post;
+(void)printBBSAction:(PBBBSAction *)action;

@end
