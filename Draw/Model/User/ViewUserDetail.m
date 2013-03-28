//
//  ViewUserDetail.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "ViewUserDetail.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "UserService.h"
#import "PPTableViewController.h"
#import "UserDetailCell.h"

@interface ViewUserDetail () {
    LoadFeedFinishBlock _finishBlock;
}

@property (retain, nonatomic) PBGameUser* pbUser;

@property (retain, nonatomic) NSMutableArray* opusList;
@property (retain, nonatomic) NSMutableArray* guessedList;
@property (retain, nonatomic) NSMutableArray* favouriateList;

@end

@implementation ViewUserDetail

- (id)init
{
    self = [super init];
    if (self) {
        _opusList = [[NSMutableArray alloc] init];
        _guessedList = [[NSMutableArray alloc] init];
        _favouriateList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_pbUser release];
    PPRelease(_opusList);
    PPRelease(_guessedList);
    PPRelease(_favouriateList);
    [super dealloc];
}

- (NSString*)getUserId
{
    return self.pbUser.userId;
}
- (PBGameUser*)queryUser
{
    return self.pbUser;
}
- (BOOL)canEdit
{
    return NO;
}
- (BOOL)needUpdate
{
    return YES;
}

- (id)initWithUserId:(NSString*)userId
              avatar:(NSString*)avatar
            nickName:(NSString*)nickName
{
    self = [self init];
    if (self) {
        PBGameUser_Builder* builder = [PBGameUser builder];
        [builder setUserId:userId];
        [builder setAvatar:avatar];
        [builder setNickName:nickName];
        self.pbUser = [builder build];
    }
    return self;
}

+ (ViewUserDetail*)viewUserDetailWithUserId:(NSString *)userId
                                     avatar:(NSString *)avatar
                                   nickName:(NSString *)nickName
{
    return [[[ViewUserDetail alloc] initWithUserId:userId avatar:avatar nickName:nickName] autorelease];
}

- (void)setPbGameUser:(PBGameUser *)pbUser
{
    self.pbUser = pbUser;
}
- (BOOL)canFollow
{
    return YES;
}
- (BOOL)canChat
{
    return YES;
}
- (BOOL)canDraw
{
    return YES;
}
- (BOOL)canBlack
{
    return YES;
}

- (BOOL)canSuperBlack
{
    return [[UserManager defaultManager] isSuperUser];
}

- (PBGameUser*)getUser
{
    return self.pbUser;
}

- (void)loadUser:(PPTableViewController*)viewController
{
    [viewController showActivityWithText:NSLS(@"kLoading")];
    [[UserService defaultService] getUserInfo:[self getUserId] resultBlock:^(int resultCode, PBGameUser *user, int relation) {
        if (resultCode == 0){

            self.pbUser = user;
            [self setRelation:relation];
            
            // reload data
            [viewController.dataTableView reloadData];
        }
    }];
    
}

- (void)loadFeedByTabAction:(int)tabAction finishBLock:(LoadFeedFinishBlock)block
{
    switch (tabAction) {
        case DetailTabActionClickFavouriate: {
            
        } break;
        case DetailTabActionClickGuessed: {
            [[FeedService defaultService] getUserFeedList:[self getUserId] offset:self.guessedList.count limit:10 delegate:self];
        } break;
        case DetailTabActionClickOpus: {
            [[FeedService defaultService] getUserOpusList:[self getUserId] offset:self.opusList.count limit:10 type:FeedListTypeUserOpus delegate:self];
        } break;
        default:
            break;
    }
    RELEASE_BLOCK(_finishBlock);
    COPY_BLOCK(_finishBlock, block);
}

#pragma mark - feed service delegate
- (void)didGetFeedList:(NSArray *)feedList
            targetUser:(NSString *)userId
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    //    [self hideActivity];
    if (resultCode == 0) {
        switch (type) {
            case FeedListTypeUserFeed: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[GuessFeed class]]) {
                        [self.guessedList addObject:((GuessFeed*)feed).drawFeed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((GuessFeed*)feed).drawFeed.wordText);
                    }
                }
                EXECUTE_BLOCK(_finishBlock, resultCode, self.guessedList);
                //                [[self detailCell] setDrawFeedList:self.guessedList];
            } break;
            case FeedListTypeUserOpus: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        [self.opusList addObject:feed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((DrawFeed*)feed).wordText);
                    }
                }
                //                UserDetailCell* cell = [self detailCell];
                //                [cell setDrawFeedList:self.opusList];
                
                EXECUTE_BLOCK(_finishBlock, resultCode, self.opusList);
            }
            default:
                break;
        }
    } else {
        EXECUTE_BLOCK(_finishBlock, resultCode, nil);
    }
}

@end
