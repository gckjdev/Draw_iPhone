//
//  MyFriendsController.m
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "MyFriendsController.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"

@interface MyFriendsController ()

@end

@implementation MyFriendsController
@synthesize titleLabel;
@synthesize editButton;
@synthesize myFollowButton;
@synthesize myFanButton;

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
    
    [titleLabel setText:NSLS(@"我的好友")];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [editButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    
    [myFollowButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [myFollowButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [myFanButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [myFanButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    
    myFollowButton.selected = YES;
    
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setEditButton:nil];
    [self setMyFollowButton:nil];
    [self setMyFanButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [titleLabel release];
    [editButton release];
    [myFollowButton release];
    [myFanButton release];
    [super dealloc];
}
@end
