//
//  BBSPostCommand.m
//  Draw
//
//  Created by gamy on 13-1-22.
//
//

#import "BBSPostCommand.h"
#import "BBSPermissionManager.h"
#import "BBSImageManager.h"


@implementation BBSPostCommand
- (id)initWithPost:(PBBBSPost *)post controller:(BBSPostDetailController *)controller
{
    self = [super init];
    if (self) {
        self.post = post;
        self.controller = controller;
    }
    return self;
}
- (void)excute
{
    PPDebug(@"<BBSPostCommand>excute, no action");
}
- (NSString *)name
{
    PPDebug(@"<BBSPostCommand>name, no name");
    return nil;
}
- (UIImage *)icon
{
    PPDebug(@"<BBSPostCommand>icon, no icon");
    return nil;
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc",self);
    PPRelease(_post);
    [super dealloc];
}

@end

@implementation BBSPostSupportCommand
-(void)excute{
    [[BBSService defaultService] createActionWithPostId:self.post.postId
                                                PostUid:self.post.postUid
                                               postText:self.post.postText
                                           sourceAction:nil
                                             actionType:ActionTypeSupport
                                                   text:nil
                                                  image:nil
                                         drawActionList:nil
                                              drawImage:nil
                                               delegate:self.controller];

}

- (NSString *)name{
    return NSLS(@"kBBSSupport");
}
- (UIImage *)icon
{
    return [[BBSImageManager defaultManager] bbsPostDetailSupport];
}
- (void)dealloc
{
    [super dealloc];
}

@end

@implementation BBSPostReplyCommand
-(void)excute{
    [CreatePostController enterControllerWithSourecePost:self.post
                                            sourceAction:nil
                                          fromController:self.controller].delegate = self.controller;
    
}
- (NSString *)name{
    return NSLS(@"kBBSReply");
}
- (UIImage *)icon
{
    return [[BBSImageManager defaultManager] bbsPostDetailComment];
}
- (void)dealloc
{
    [super dealloc];
}

@end

@interface BBSPostTransferCommand()
{

}
@property(nonatomic, retain)NSArray *optionBoardList;
@end

@implementation BBSPostTransferCommand

- (void)optionView:(BBSOptionView *)optionView didSelectedButtonIndex:(NSInteger)index
{
    PBBBSBoard *board = [self.optionBoardList objectAtIndex:index];
    PPDebug(@"click At index = %d, board id = %@, board name = %@",index, board.boardId, board.name);
    [[BBSService defaultService] editPost:self.post
                                  boardId:board.boardId
                                   status:self.post.status
                                     info:nil
                                 delegate:self.controller];
}

- (void)initOptionBoardList
{
    if (self.optionBoardList == nil) {
    self.optionBoardList = [[BBSManager defaultManager] allSubBoardList];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.boardId<>%@",self.post.boardId];
    self.optionBoardList = [self.optionBoardList filteredArrayUsingPredicate:predicate];
    }
}

- (NSArray *)optionBoardNameList
{
    [self initOptionBoardList];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:[self.optionBoardList count]];
    for(PBBBSBoard *board in self.optionBoardList){
        [list addObject:[board name]];
    }
    return list;
}

-(void)excute{
    NSArray *nameList = [self optionBoardNameList];
    BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:nameList delegate:self];
    [sheet showInView:self.controller.view
          showAtPoint:self.controller.view.center
             animated:YES];
    [sheet release];
}
- (NSString *)name{
    return NSLS(@"kBBSTransfer");
}
- (UIImage *)icon
{
    return [[BBSImageManager defaultManager] bbsPostDetailTransfer];
}
- (void)dealloc
{
    PPRelease(_optionBoardList);
    [super dealloc];
}


@end



@implementation BBSPostTopCommand


-(void)excute{
    
    
    BBSPostStatus status = BBSPostStatusTop;
    
    if (self.post.status == BBSPostStatusTop) {
        status = BBSPostStatusNormal;
        [self.controller showActivityWithText:NSLS(@"kToUNToping")];        
    }else{
        [self.controller showActivityWithText:NSLS(@"kToToping")];
    }

    
    [[BBSService defaultService] editPost:self.post
                                  boardId:nil
                                   status:status
                                     info:nil
                                 delegate:self.controller];
}

- (NSString *)name{
    return NSLS(@"kBBSToTop");
}

- (UIImage *)icon
{
    if (self.post.status == BBSPostStatusTop) {
        return [[BBSImageManager defaultManager] bbsPostDetailUnTop];
    }
    return [[BBSImageManager defaultManager] bbsPostDetailToTop];
}

- (void)dealloc
{
    [super dealloc];
}


@end

@implementation BBSPostDeleteCommand

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.controller showActivityWithText:NSLS(@"kDeleting")];
        [[BBSService defaultService] deletePost:self.post delegate:self.controller];
    }
}

-(void)excute{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS(@"kDeletePostAlertTitle") message:NSLS(@"kDeletePostAlertMessage") delegate:self cancelButtonTitle:NSLS(@"kCancel") otherButtonTitles:NSLS(@"kOK"), nil];
    [alert show];
    PPRelease(alert);
}
- (NSString *)name{
    return NSLS(@"kBBSDelete");
}

- (UIImage *)icon
{
    return [[BBSImageManager defaultManager] bbsPostDetailDelete];
}

- (void)dealloc
{
    [super dealloc];
}

@end


