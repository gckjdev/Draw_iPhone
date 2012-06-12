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
- (void)registerKeyboardNotification;
- (void)deregsiterKeyboardNotification;

@end


@implementation ChatDetailController
@synthesize titleLabel;
@synthesize graffitiButton;
@synthesize inputView;
@synthesize inputTextField;
@synthesize sendButton;
@synthesize friendUserId = _friendUserId;

- (void)dealloc {
    [_friendUserId release];
    [titleLabel release];
    [graffitiButton release];
    [sendButton release];
    [inputTextField release];
    [inputView release];
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
    
    
    // Add a single tap Recognizer
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1; // For single tap
    [self.dataTableView addGestureRecognizer:singleTapRecognizer];
    [singleTapRecognizer release];
    
    

    PPDebug(@"%@",_friendUserId);
    self.dataList = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:_friendUserId];
    PPDebug(@"%d",[dataList count]);
    //[self findAllMessages];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setGraffitiButton:nil];
    [self setSendButton:nil];
    [self setInputTextField:nil];
    [self setInputView:nil];
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

- (void)didSendMessage:(int)resultCode
{
    if (resultCode == 0) {
        [inputTextField setText:@""];
        //to do
    } else {
        [self popupMessage:NSLS(@"kSendMessageFailed") title:nil];
    }
    
    [inputTextField resignFirstResponder];
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
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:14 topCapHeight:14]];
    bubbleImageView.backgroundColor =[UIColor clearColor];
    
    
    if ([message.text length] > 0) {
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(BUBBLE_WIDTH_MAX, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        
        UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, size.width+10, size.height+10)];
        bubbleText.backgroundColor = [UIColor clearColor];
        bubbleText.font = font;
        bubbleText.numberOfLines = 0;
        bubbleText.lineBreakMode = UILineBreakModeCharacterWrap;
        bubbleText.text = message.text;
        
        bubbleImageView.frame = CGRectMake(0.0f, 0.0f, 200.0f, size.height+40.0f);
        if(fromSelf)
            returnView.frame = CGRectMake(120.0f, 10.0f, 200.0f, size.height+50.0f);
        else
            returnView.frame = CGRectMake(0.0f, 10.0f, 200.0f, size.height+50.0f);
        
        [bubbleImageView addSubview:bubbleText];
        [bubbleText release];
    }else {
        //to do
    }
    
    [returnView addSubview:bubbleImageView];
    [bubbleImageView release];
    
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

- (IBAction)clickSendButton:(id)sender {
    
    [[ChatService defaultService] sendMessage:self 
                                 friendUserId:_friendUserId 
                                         text:inputTextField.text 
                                         data:nil];
}


- (void)handleSingleTapFrom:(UITapGestureRecognizer*)recognizer {
    [inputTextField resignFirstResponder];
}


#pragma mark super Keyboard Methods
- (void)keyboardDidShowWithRect:(CGRect)keyboardRect
{
    CGRect frame = CGRectMake(0, 460 - keyboardRect.size.height - inputView.frame.size.height, inputView.frame.size.width, inputView.frame.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    inputView.frame = frame;
    [UIImageView commitAnimations]; 
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    CGRect frame = CGRectMake(0, 460 - inputView.frame.size.height, inputView.frame.size.width, inputView.frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    inputView.frame = frame;
    [UIImageView commitAnimations]; 
}


@end
