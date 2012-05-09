//
//  SearchUserController.m
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "SearchUserController.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"

@interface SearchUserController ()

@end

@implementation SearchUserController
@synthesize searchButton;
@synthesize titleLabel;
@synthesize resultLabel;
@synthesize inputTextField;

- (void)dealloc {
    [searchButton release];
    [titleLabel release];
    [resultLabel release];
    [inputTextField release];
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
    [titleLabel setText:@"添加好友"];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [searchButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    
    resultLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:50.0/255.0 blue:12.0/255.0 alpha:1.0];
    resultLabel.hidden = YES;
    
    
    dataTableView.separatorColor = [UIColor colorWithRed:175.0/255.0 green:124.0/255.0 blue:68.0/255.0 alpha:1.0];
    dataTableView.hidden = YES;
}

- (void)viewDidUnload
{
    [self setSearchButton:nil];
    [self setTitleLabel:nil];
    [self setResultLabel:nil];
    [self setInputTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma -mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchUserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setTextColor:[UIColor brownColor]];
        
        UIImageView *avatarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, (55-39)/2, 37, 39)];
        [avatarBackground setImage:[UIImage imageNamed:@"user_picbg.png"]];
        [cell.contentView addSubview:avatarBackground];
        [avatarBackground release];
    }
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (55-39)/2, 37, 36)];
    [avatarImageView setImage:[UIImage imageNamed:@"man1.png"]];
    [cell.contentView addSubview:avatarImageView];
    [avatarImageView release];
    
    UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(39+6, (55-40)/2, 100, 40)];
    nickLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:50.0/255.0 blue:12.0/255.0 alpha:1.0];
    nickLabel.text = [dataList objectAtIndex:[indexPath row]];
    [cell.contentView addSubview:nickLabel];
    [nickLabel release];
    
    //UIButton *button = [[UIButton alloc] initWithFrame:];
    //[button ]
    
    return cell;
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backgroundTap:(id)sender
{
    [inputTextField resignFirstResponder];
}

- (IBAction)clickSearch:(id)sender
{
    [inputTextField resignFirstResponder];
    //to do
    
    if ([inputTextField.text length] == 0) {
        resultLabel.hidden = NO;
        [resultLabel setText:@"没有找到此用户"];
    }else {
        self.dataList = [NSArray arrayWithObjects:@"Jenny", @"Jenny", @"Jenny", @"Jenny",nil];
        dataTableView.hidden = NO;
        [dataTableView reloadData];
    }
}

@end
