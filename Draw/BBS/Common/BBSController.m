//
//  BBSController.m
//  Draw
//
//  Created by gamy on 13-3-20.
//
//

#import "BBSController.h"
#import "CommonUserInfoView.h"

@interface BBSController ()

@end

@implementation BBSController

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
	// Do any additional setup after loading the view.
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
//    self.tempURL = url;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser release];
    [nc release];
}

- (void)didClickDrawImageWithPost:(PBBBSPost *)post
{
    
}

- (void)didClickDrawImageWithAction:(PBBBSAction *)action
{
    
}

@end
