//
//  UserTutorialMainController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "UserTutorialMainController.h"
#import "UIViewController+BGImage.h"

@interface UserTutorialMainController ()

@end

@implementation UserTutorialMainController

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
    
    // set title view
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kUserTutorialMainTitle")];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickAdd:)];
    [[CommonTitleView titleView:self.view] setRightButtonTitle:NSLS(@"kAddTutorial")];
    
    // set background
    [self setDefaultBGImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
