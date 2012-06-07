//
//  ChatListController.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatListController.h"
#import "ChatCell.h"
#import "ShareImageManager.h"
#import "ChatDetailController.h"

@interface ChatListController ()

- (IBAction)clickBack:(id)sender;

@end

@implementation ChatListController
@synthesize titleLabel;
@synthesize addChatButton;

- (void)dealloc {
    [titleLabel release];
    [addChatButton release];
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
    [titleLabel setText:NSLS(@"kChatListTitle")];
    
    //test data
    self.dataList = [NSArray arrayWithObjects:@"t", @"t", @"t", @"t", @"t", @"t", @"t", @"t", nil];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setAddChatButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ChatCell getCellIdentifier];
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ChatCell createCell:self];
    }
    
    //test data
    [cell.avatarImage setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatDetailController *controller = [[ChatDetailController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
