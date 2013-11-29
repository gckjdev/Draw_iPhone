//
//  SearchPostController.m
//  Draw
//
//  Created by Gamy on 13-10-23.
//
//

#import "SearchPostController.h"
#import "BBSViewManager.h"
#import "BBSPostDetailController.h"
#import "BBSPostCell.h"
#import "CommonUserInfoView.h"
#import "PPConfigManager.h"
#import "DrawPlayer.h"
#import "ImagePlayer.h"
#import "GroupModelExt.h"



@interface SearchPostController ()

@end


@implementation SearchPostController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BBSService *)bbsService
{
    return (self.forGroup ? [BBSService groupTopicService] : [BBSService defaultService]);
}

- (void)loadDataWithKey:(NSString *)key tabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kSearching")];
    TableTab *tab = [_tabManager tabForID:tabID];
    [[self bbsService] searchPostListByKeyWord:key
                                       inGroup:self.group.groupId
                                        offset:tab.offset
                                         limit:tab.limit
                                       hanlder:^(NSInteger resultCode, NSArray *postList, NSInteger tag) {
        [self hideActivity];
        if (resultCode == 0) {
            [self finishLoadDataForTabID:tabID resultList:postList];
        }else{
            [self failLoadDataForTabID:tabID];
        }
    }];

}


- (CGFloat)heightForData:(id)data
{
    PBBBSPost *post = data;
	return [BBSPostCell getCellHeightWithBBSPost:post];
}
- (void)didSelectedCellWithData:(id)data
{
    PBBBSPost *post = data;
    
    if (self.forGroup) {
        [BBSPostDetailController enterPostDetailControllerWithPost:post group:self.group fromController:self animated:YES];
    }else{
        [BBSPostDetailController enterPostDetailControllerWithPost:post
                                                    fromController:self
                                                          animated:YES];
    }
}
- (UITableViewCell *)cellForData:(id)data
{
    NSString *CellIdentifier = [BBSPostCell getCellIdentifier];
	BBSPostCell *cell = [self.dataTableView
                         dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BBSPostCell createCell:self];
	}
    PBBBSPost *post = data;
    [cell updateCellWithBBSPost:post];
    cell.backgroundColor = [UIColor clearColor];
	return cell;
}

- (NSString *)headerTitle
{
    return self.forGroup ? NSLS(@"kSearchTopic") : NSLS(@"kSearchPost");
}
- (NSString *)searchTips
{
    return NSLS(@"kBBSSearchPlaceholder");
}
- (NSString *)historyStoreKey
{
    return self.forGroup ? @"TopicSearchHistory" : @"BBSSearchHistory";
}


//delegate


- (void)didClickUserAvatar:(PBBBSUser *)user
{
    PPDebug(@"<didClickUserAvatar>, userId = %@",user.userId);
    [CommonUserInfoView showPBBBSUser:user
                         inController:self
                           needUpdate:YES
                              canChat:YES];
    
}



- (void)didClickImageWithURL:(NSURL *)url
{
//    self.tempURL = url;
    [[ImagePlayer defaultPlayer] playWithUrl:url displayActionButton:YES onViewController:self];
}

- (void)didClickDrawImageWithPost:(PBBBSPost *)post
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[self bbsService] getBBSDrawDataWithPostId:post.postId
                                       actionId:nil
                                       delegate:self];
}

- (void)didClickDrawImageWithAction:(PBBBSAction *)action
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[self bbsService] getBBSDrawDataWithPostId:nil
                                       actionId:action.actionId
                                       delegate:self];
    
}

#pragma mark-- BBS Service Delegate

- (void)didGetBBSDrawActionList:(NSMutableArray *)drawActionList
                drawDataVersion:(NSInteger)version
                     canvasSize:(CGSize)canvasSize
                         postId:(NSString *)postId
                       actionId:(NSString *)actionId
                     fromRemote:(BOOL)fromRemote
                     resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        BOOL isNewVersion = [PPConfigManager currentDrawDataVersion] < version;
        ReplayObject *obj = [ReplayObject obj];
        obj.actionList = drawActionList;
        obj.isNewVersion = isNewVersion;
        obj.canvasSize = canvasSize;
        obj.layers = [DrawLayer defaultOldLayersWithFrame:CGRectFromCGSize(canvasSize)];
        DrawPlayer *player =[DrawPlayer playerWithReplayObj:obj];
        [player showInController:self];
        
    }else{
        PPDebug(@"<didGetBBSDrawActionList> fail!, resultCode = %d",resultCode);
    }
}


@end
