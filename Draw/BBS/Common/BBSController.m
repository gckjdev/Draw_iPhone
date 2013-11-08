//
//  BBSController.m
//  Draw
//
//  Created by gamy on 13-3-20.
//
//

#import "BBSController.h"
#import "CommonUserInfoView.h"
#import "PPConfigManager.h"
#import "DrawPlayer.h"
#import "ImagePlayer.h"

@interface BBSController ()

@property (retain, nonatomic) NSURL *tempURL;

@end

@implementation BBSController

- (void)dealloc
{
    PPRelease(_tempURL);
    [super dealloc];
}

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
    [self.dataTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
    self.tempURL = url;
    [[ImagePlayer defaultPlayer] playWithUrl:url displayActionButton:YES onViewController:self];
}

- (void)didClickDrawImageWithPost:(PBBBSPost *)post
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[BBSService defaultService] getBBSDrawDataWithPostId:post.postId
                                                 actionId:nil
                                                 delegate:self];
}

- (void)didClickDrawImageWithAction:(PBBBSAction *)action
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[BBSService defaultService] getBBSDrawDataWithPostId:nil
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
