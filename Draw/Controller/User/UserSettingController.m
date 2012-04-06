//
//  UserSettingController.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserSettingController.h"
#import "PPDebug.h"
#import "UserManager.h"
#import "LocaleUtils.h"
#import "ShareImageManager.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"

enum{
    SECTION_LANGUAGE = 0,
    SECTION_COUNT
};



@implementation UserSettingController
@synthesize titleLabel;
@synthesize avatarButton;
@synthesize tableViewBG;

- (void)updateRowIndexs
{
    rowOfPassword = 0;
    rowOfNickName = 1;
    rowOfLanguage = 2;
    if ([LocaleUtils isChina]) {
        rowOfSinaWeibo = 3;
        rowOfQQWeibo = 4;
        rowOfFacebook = 5;
        rowNumber = 6;
    }else{
        rowOfSinaWeibo = rowOfQQWeibo = -1;        
        rowOfFacebook = 3;
        rowNumber = 4;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self updateRowIndexs];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateAvatar:(UIImage *)image
{
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    userManager = [UserManager defaultManager];
    [titleLabel setText:NSLS(@"kSettings")];
    [tableViewBG setImage:[[ShareImageManager defaultManager]whitePaperImage]];
    
    
    imageView = [[HJManagedImageV alloc] initWithFrame:avatarButton.bounds];
    [imageView clear];
    if (userManager.avatarImage){
        [imageView setImage:userManager.avatarImage];
    }
    else{
        [imageView setImage:[UIImage imageNamed:DEFAULT_AVATAR_BUNDLE]];
    }
    [GlobalGetImageCache() manage:imageView];
    [self addSubview:imageView];

    
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTableViewBG:nil];
    [self setAvatarButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rowNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSInteger row = indexPath.row;
    if (row == rowOfPassword) {
        [cell.textLabel setText:NSLS(@"kPassword")];           
    }else if(row == rowOfNickName)
    {
        [cell.textLabel setText:NSLS(@"kNickname")];           
    }else if(row == rowOfLanguage)
    {
        [cell.textLabel setText:NSLS(@"kLanguageSettings")];           
    }else if(row == rowOfSinaWeibo)
    {
        [cell.textLabel setText:NSLS(@"kSinaWeibo")];              
        if ([userManager hasBindSinaWeibo]) {
            [cell.detailTextLabel setText:NSLS(@"kBind")];            
        }
    }else if(row == rowOfQQWeibo)
    {
        [cell.textLabel setText:NSLS(@"kQQWeibo")];    
        if ([userManager hasBindQQWeibo]) {
            [cell.detailTextLabel setText:NSLS(@"kBind")];            
        }
    }else if(row == rowOfFacebook)
    {
        [cell.textLabel setText:NSLS(@"kFacebook")];     
        if ([userManager hasBindFacebook]) {
            [cell.detailTextLabel setText:NSLS(@"kBind")];            
        }
    }
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    if (row == rowOfLanguage) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLanguageSelection" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kChinese") otherButtonTitles:NSLS(@"kEnglish"), nil];
        LanguageType type = [userManager getLanguageType];
        [actionSheet setDestructiveButtonIndex:type - 1];
        [actionSheet showInView:self.view];
        [actionSheet release];        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == [actionSheet cancelButtonIndex] || buttonIndex == [actionSheet destructiveButtonIndex]) {
        return;
    }else {
        LanguageType type = buttonIndex + 1;
        [userManager setLanguageType:type];
    }
}

- (IBAction)clickAvatar:(id)sender {
    NSLog(@"clickAvatar");
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc {
    [titleLabel release];
    [tableViewBG release];
    [avatarButton release];
    [super dealloc];
}
@end
