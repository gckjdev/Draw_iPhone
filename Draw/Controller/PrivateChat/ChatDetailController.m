//
//  ChatDetailController.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatDetailController.h"
#import "DeviceDetection.h"
#import "ChatMessage.h"
#import "ChatMessageManager.h"
#import "UserManager.h"

@interface ChatDetailController ()

@property (retain, nonatomic) NSString *friendUserId;

- (IBAction)clickBack:(id)sender;

@end


@implementation ChatDetailController
@synthesize titleLabel;
@synthesize graffitiButton;
@synthesize friendUserId = _friendUserId;

- (void)dealloc {
    [_friendUserId release];
    [titleLabel release];
    [graffitiButton release];
    [super dealloc];
}

- (id)initWithFriendUserId:(NSString *)frindUserId
{
    self = [super init];
    if (self) {
        self.friendUserId = frindUserId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    self.dataList = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:_friendUserId];
    [self findAllMessages];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setGraffitiButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)findAllMessages
{
    [[ChatService defaultService] findAllMessages:self friendUserId:_friendUserId starOffset:0 maxCount:100];
}

- (void)didFindAllMessagesByFriendUserId:(NSArray *)totalList
{
    self.dataList = totalList;
    [dataTableView reloadData];
}

#define BUBBLE_WIDTH_MAX_IPHONE 200.0
#define BUBBLE_WIDTH_MAX_IPAD   400.0
#define BUBBLE_WIDTH_MAX    (([DeviceDetection isIPAD])?(BUBBLE_WIDTH_MAX_IPAD):(BUBBLE_WIDTH_MAX_IPHONE))

- (UIView *)bubbleView:(ChatMessage *)message
{
    UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	returnView.backgroundColor = [UIColor clearColor];
    
    BOOL fromSelf = [message.from isEqualToString:[[UserManager defaultManager] userId]];
	UIImage *bubble = [UIImage imageNamed:fromSelf ? @"sent_message.png" : @"receive_message.png"];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    bubbleImageView.backgroundColor =[UIColor clearColor];
    [returnView addSubview:bubbleImageView];
    [bubbleImageView release];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    if (imageView.frame.size.width > 200) {
//        CGRect rect = imageView.frame;
//        CGFloat Multiple = BUBBLE_WIDTH_MAX / rect.size.width;
//        imageView.frame = CGRectMake(0, 0, BUBBLE_WIDTH_MAX, rect.size.height * Multiple);
//    }
    
    return returnView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *message = (ChatMessage *)[dataList objectAtIndex:indexPath.row];
    UIView *view = [self bubbleView:message];
    return view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"chatDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    ChatMessage *message = (ChatMessage *)[dataList objectAtIndex:indexPath.row];
    UIView *view = [self bubbleView:message];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:view];
    
    return cell;
}


- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickGraffitiButton:(id)sender {
}

@end
